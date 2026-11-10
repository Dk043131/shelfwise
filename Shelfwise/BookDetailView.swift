import SwiftUI
import PhotosUI
import UIKit

public struct BookDetailView: View {
    @Binding var book: Book
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingLogSheet: Bool = false
    @State private var showingCamera: Bool = false
    @State private var showingPhotoPicker: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    // Captured photo awaiting summary text
    @State private var photoForSummarySheet: UIImage? = nil
    @State private var selectedNoteForZoom: DailyPhotoNote? = nil
    @State private var showingAlreadyLoggedAlert: Bool = false
    @State private var selectedDetailTab: DetailTab = .overview
    @State private var notePageSearchQuery: String = ""
    
    enum DetailTab: String, CaseIterable, Identifiable {
        case overview = "Overview"
        case notes = "Notes & Highlights"
        var id: String { rawValue }
    }
    
    public init(book: Binding<Book>) {
        self._book = book
    }
    
    private var bookNotes: [DailyPhotoNote] {
        dataManager.photoNotes.filter { $0.bookId == book.id }
    }
    
    private var filteredBookNotes: [DailyPhotoNote] {
        let trimmed = notePageSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return bookNotes }
        
        let lower = trimmed.lowercased()
        let searchInt = Int(trimmed)
        
        return bookNotes.filter { note in
            // Match page number directly
            if let searchPage = searchInt {
                if let p = note.pageNumber, p == searchPage { return true }
                if let from = note.fromPage, let to = note.toPage, (from...to).contains(searchPage) { return true }
            }
            // Match page description text (e.g. "page 42", "42-50")
            if let desc = note.pageRangeDescription?.lowercased(), desc.contains(lower) {
                return true
            }
            // Match summary text or takeaways
            if let summary = note.summaryText?.lowercased(), summary.contains(lower) {
                return true
            }
            return false
        }
    }
    
    private var hasLoggedToday: Bool {
        dataManager.hasLoggedToday(for: book.id)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                NocturneTheme.bgVoid.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header: Large Book Cover with Ambient Halo
                        VStack(spacing: 16) {
                            ZStack {
                                // Ambient backlight glow
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color(hex: book.gradientHexes.first ?? "#8B5CF6").opacity(0.4),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 10,
                                            endRadius: 140
                                        )
                                    )
                                    .frame(width: 180, height: 240)
                                    .blur(radius: 20)
                                
                                BookCoverView(book: book, width: 130, height: 186, cornerRadius: 12)
                            }
                            
                            VStack(spacing: 6) {
                                Text(book.title)
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                Text(book.author)
                                    .font(.subheadline)
                                    .foregroundColor(Color.white.opacity(0.65))
                                
                                // Dominant or Custom topics tag buttons
                                HStack(spacing: 8) {
                                    if !book.dominantTopics.isEmpty {
                                        ForEach(book.dominantTopics) { topic in
                                            HStack(spacing: 4) {
                                                Image(systemName: topic.systemIcon)
                                                    .font(.caption2)
                                                Text(topic.rawValue)
                                                    .font(.caption.bold())
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Capsule().fill(topic.accentColor.opacity(0.2)))
                                            .overlay(Capsule().stroke(topic.accentColor, lineWidth: 1))
                                            .foregroundColor(topic.accentColor)
                                        }
                                    } else {
                                        ForEach(book.customTopics, id: \.self) { ct in
                                            HStack(spacing: 4) {
                                                Image(systemName: "tag.fill")
                                                    .font(.caption2)
                                                Text(ct)
                                                    .font(.caption.bold())
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Capsule().fill(Color.teal.opacity(0.2)))
                                            .overlay(Capsule().stroke(Color.teal, lineWidth: 1))
                                            .foregroundColor(.teal)
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.top, 8)
                        
                        // Reading Progress Card
                        VStack(spacing: 16) {
                            HStack {
                                Text("READING PROGRESS")
                                    .font(.caption.bold())
                                    .foregroundColor(Color.white.opacity(0.5))
                                    .tracking(1.2)
                                
                                Spacer()
                                
                                Text("\(book.currentPage) of \(book.totalPages) pages")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                            
                            // Visual Progress Bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.08))
                                        .frame(height: 8)
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                colors: [NocturneTheme.purpleBright, Color(red: 0.38, green: 0.82, blue: 0.98)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * CGFloat(book.progressFraction), height: 8)
                                }
                            }
                            .frame(height: 8)
                            
                            HStack {
                                Text("\(book.progressPercentage)% complete")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(NocturneTheme.purpleBright)
                                
                                Spacer()
                                
                                Button(action: {
                                    if hasLoggedToday {
                                        showingAlreadyLoggedAlert = true
                                    } else {
                                        showingLogSheet = true
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: hasLoggedToday ? "checkmark.circle.fill" : "pencil.line")
                                        Text(hasLoggedToday ? "Logged Today" : "Update Progress")
                                    }
                                    .font(.caption.bold())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(hasLoggedToday ? Color.green.opacity(0.2) : Color.white.opacity(0.08)))
                                    .overlay(Capsule().stroke(hasLoggedToday ? Color.green : Color.white.opacity(0.15), lineWidth: 1))
                                    .foregroundColor(hasLoggedToday ? .green : .white)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(18)
                        .liquidCard(cornerRadius: 18)
                        
                        // Segmented Tab Picker: Overview vs Notes
                        HStack(spacing: 0) {
                            ForEach(DetailTab.allCases) { tab in
                                let isSelected = (selectedDetailTab == tab)
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedDetailTab = tab
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: tab == .overview ? "doc.text.magnifyingglass" : "note.text")
                                            .font(.caption)
                                        Text(tab.rawValue)
                                            .font(.subheadline.bold())
                                        if tab == .notes && !bookNotes.isEmpty {
                                            Text("\(bookNotes.count)")
                                                .font(.caption2.bold())
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Capsule().fill(isSelected ? NocturneTheme.purpleBright : Color.white.opacity(0.15)))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .foregroundColor(isSelected ? .white : Color.white.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        isSelected ? Capsule().fill(NocturneTheme.purplePrimary.opacity(0.35)) : Capsule().fill(Color.clear)
                                    )
                                    .overlay(
                                        isSelected ? Capsule().stroke(NocturneTheme.purpleBright, lineWidth: 1) : nil
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(4)
                        .background(Capsule().fill(Color.white.opacity(0.06)))
                        
                        // Tab Content
                        if selectedDetailTab == .overview {
                            // Core Psychological Takeaway / Overview
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "quote.opening")
                                        .foregroundColor(NocturneTheme.purpleBright)
                                    Text(book.isCurriculumBook ? "DARK PSYCHOLOGY CURRICULUM SYLLABUS" : "BOOK OVERVIEW & KEY TAKEAWAYS")
                                        .font(.caption.bold())
                                        .foregroundColor(Color.white.opacity(0.5))
                                        .tracking(1.2)
                                }
                                
                                Text(book.keyInsight.isEmpty ? "No detailed key insight provided yet. As you read, log notes and takeaways to synthesize this book." : book.keyInsight)
                                    .font(.subheadline)
                                    .foregroundColor(Color.white.opacity(0.85))
                                    .lineSpacing(4)
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                // Quick Stats Row
                                HStack(spacing: 20) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Curriculum Level")
                                            .font(.caption2)
                                            .foregroundColor(Color.white.opacity(0.45))
                                        Text(book.isCurriculumBook ? "Level \(book.levelNumber)" : "Personal Shelf")
                                            .font(.caption.bold())
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Saved Notes")
                                            .font(.caption2)
                                            .foregroundColor(Color.white.opacity(0.45))
                                        Text("\(bookNotes.count) visual notes")
                                            .font(.caption.bold())
                                            .foregroundColor(NocturneTheme.purpleBright)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.top, 4)
                            }
                            .padding(18)
                            .liquidCard(cornerRadius: 18)
                        } else {
                            // Notes & Highlights Tab with Search by Page Number & Notes
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("NOTES & HIGHLIGHTS")
                                            .font(.caption.bold())
                                            .foregroundColor(Color.white.opacity(0.5))
                                            .tracking(1.2)
                                        Text("Search notes by page number or takeaways")
                                            .font(.caption2)
                                            .foregroundColor(Color.white.opacity(0.45))
                                    }
                                    
                                    Spacer()
                                    
                                    // Direct Camera Button
                                    Button(action: {
                                        showingCamera = true
                                    }) {
                                        HStack(spacing: 5) {
                                            Image(systemName: "camera.fill")
                                            Text("Snap Note")
                                        }
                                        .font(.caption.bold())
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(Capsule().fill(NocturneTheme.purplePrimary.opacity(0.3)))
                                        .overlay(Capsule().stroke(NocturneTheme.purpleBright, lineWidth: 1))
                                        .foregroundColor(.white)
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                // Search Bar for Notes by Page Number or Keyword
                                HStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(Color.white.opacity(0.4))
                                        .font(.caption)
                                    
                                    TextField("Search by page number (e.g. 42) or note text...", text: $notePageSearchQuery)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    
                                    if !notePageSearchQuery.isEmpty {
                                        Button(action: { notePageSearchQuery = "" }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(Color.white.opacity(0.4))
                                                .font(.caption)
                                        }
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(NocturneTheme.bgSurfaceElevated)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08), lineWidth: 1))
                                )
                                
                                if filteredBookNotes.isEmpty {
                                    VStack(spacing: 10) {
                                        Image(systemName: notePageSearchQuery.isEmpty ? "camera.viewfinder" : "text.magnifyingglass")
                                            .font(.system(size: 30))
                                            .foregroundColor(Color.white.opacity(0.3))
                                        Text(notePageSearchQuery.isEmpty ? "No visual notes yet for this book.\nTap 'Snap Note' to take photos of pages." : "No notes found matching \"\(notePageSearchQuery)\".\nTry another page number.")
                                            .font(.caption)
                                            .foregroundColor(Color.white.opacity(0.5))
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 24)
                                } else {
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                        ForEach(filteredBookNotes) { note in
                                            Button(action: {
                                                selectedNoteForZoom = note
                                            }) {
                                                AppleNotePhotoCard(note: note)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                            .padding(18)
                            .liquidCard(cornerRadius: 18)
                        }
                        
                        // Bottom Actions: 1 Log per Day Rule
                        VStack(spacing: 8) {
                            if hasLoggedToday {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                    Text("You have already logged your study session for today!")
                                        .font(.footnote.weight(.medium))
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .liquidCard(cornerRadius: 14)
                            } else {
                                Button(action: { showingLogSheet = true }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Log Today's Pages Read")
                                    }
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(NocturneTheme.purplePrimary)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Curriculum Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                            Text("Back")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $showingLogSheet) {
                LogPagesSheet(book: $book)
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView { capturedImg in
                    self.photoForSummarySheet = capturedImg
                }
                .ignoresSafeArea()
            }
            .sheet(item: $photoForSummarySheet) { img in
                AddNoteSummarySheet(initialImage: img, book: book)
            }
            .sheet(item: $selectedNoteForZoom) { note in
                ZoomablePhotoNoteSheet(note: note)
            }
            .alert("Daily Log Completed", isPresented: $showingAlreadyLoggedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You have already logged today's reading for \"\(book.title)\". The curriculum allows 1 log per day to build sustainable daily habits.")
            }
        }
    }
}
