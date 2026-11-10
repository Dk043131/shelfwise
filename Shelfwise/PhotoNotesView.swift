import SwiftUI
import UIKit

public struct PhotoNotesView: View {
    @ObservedObject private var dataManager = DataManager.shared
    
    @State private var selectedFilterBookId: UUID? = nil
    @State private var showingCamera: Bool = false
    @State private var showingBookPickerBeforeCamera: Bool = false
    @State private var capturedImageForSummary: UIImage? = nil
    @State private var targetBookForCapture: Book? = nil
    @State private var selectedNoteForDetail: DailyPhotoNote? = nil
    @State private var showingSyncAlert: Bool = false
    
    private var filteredNotes: [DailyPhotoNote] {
        if let filterId = selectedFilterBookId {
            return dataManager.photoNotes.filter { $0.bookId == filterId }
        }
        return dataManager.photoNotes
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                NocturneTheme.bgVoid.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Cloud Sync Status Banner
                        cloudStatusHeader
                        
                        // Book Filter Chips
                        bookFilterBar
                        
                        // Empty State or Notes Gallery (Apple Notes Style)
                        if filteredNotes.isEmpty {
                            emptyNotesPlaceholder
                        } else {
                            notesGrid
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 90) // space for floating bottom bar
                }
                
                // Floating Quick Snap Camera Button (Bottom Right)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button(action: startCameraCapture) {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.headline)
                                Text("Snap Note")
                                    .font(.subheadline.bold())
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(NocturneTheme.purplePrimary)
                                    .overlay(Capsule().stroke(NocturneTheme.purpleBright, lineWidth: 1))
                            )
                            .shadow(color: NocturneTheme.purplePrimary.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Photo Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dataManager.syncAllNotesToCloud()
                        showingSyncAlert = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: dataManager.isCloudSyncing ? "arrow.triangle.2.circlepath.icloud.fill" : "icloud.and.arrow.up.fill")
                                .font(.caption)
                            Text(dataManager.isCloudSyncing ? "Syncing..." : "Sync Cloud")
                                .font(.caption.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.white.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(item: $selectedNoteForDetail) { note in
                ZoomablePhotoNoteSheet(note: note)
            }
            .sheet(isPresented: $showingBookPickerBeforeCamera) {
                AssignBookToNoteSheet { chosenBook in
                    targetBookForCapture = chosenBook
                    showingBookPickerBeforeCamera = false
                    showingCamera = true
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView { img in
                    self.capturedImageForSummary = img
                }
                .ignoresSafeArea()
            }
            .sheet(item: $capturedImageForSummary) { img in
                if let book = targetBookForCapture ?? dataManager.books.first {
                    AddNoteSummarySheet(initialImage: img, book: book)
                }
            }
            .alert("Cloud Synchronization", isPresented: $showingSyncAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("All your daily photo notes and summaries have been uploaded to iCloud storage. Fast, encrypted, and backed up.")
            }
        }
    }
    
    private func startCameraCapture() {
        if let currentFilterId = selectedFilterBookId,
           let book = dataManager.books.first(where: { $0.id == currentFilterId }) {
            targetBookForCapture = book
            showingCamera = true
        } else if let readingBook = dataManager.books.first(where: { $0.status == .reading }) {
            targetBookForCapture = readingBook
            showingCamera = true
        } else {
            showingBookPickerBeforeCamera = true
        }
    }
    
    // MARK: - Cloud Status Header
    private var cloudStatusHeader: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "icloud.fill")
                    .foregroundColor(.cyan)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("iCloud Visual Vault")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.white)
                    
                    Text("\(dataManager.photoNotes.count) visual notes secured • Realtime backup")
                        .font(.caption2)
                        .foregroundColor(Color.white.opacity(0.55))
                }
            }
            
            Spacer()
            
            if dataManager.isCloudSyncing {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(.cyan)
            } else {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Synced")
                        .font(.caption2.bold())
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.green.opacity(0.15)))
            }
        }
        .padding(14)
        .liquidCard(cornerRadius: 16)
    }
    
    // MARK: - Book Filter Bar
    private var bookFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button(action: { selectedFilterBookId = nil }) {
                    Text("All Books (\(dataManager.photoNotes.count))")
                        .font(.caption.weight(selectedFilterBookId == nil ? .bold : .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            Capsule().fill(selectedFilterBookId == nil ? NocturneTheme.purplePrimary.opacity(0.3) : Color.white.opacity(0.06))
                        )
                        .overlay(
                            Capsule().stroke(selectedFilterBookId == nil ? NocturneTheme.purpleBright : Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .foregroundColor(selectedFilterBookId == nil ? .white : Color.white.opacity(0.7))
                }
                .buttonStyle(.plain)
                
                ForEach(dataManager.books.filter { $0.notesCount > 0 }) { book in
                    Button(action: { selectedFilterBookId = book.id }) {
                        HStack(spacing: 4) {
                            Text(book.title)
                                .font(.caption.weight(selectedFilterBookId == book.id ? .bold : .medium))
                                .lineLimit(1)
                            Text("(\(book.notesCount))")
                                .font(.caption2)
                                .foregroundColor(Color.white.opacity(0.5))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            Capsule().fill(selectedFilterBookId == book.id ? NocturneTheme.purplePrimary.opacity(0.3) : Color.white.opacity(0.06))
                        )
                        .overlay(
                            Capsule().stroke(selectedFilterBookId == book.id ? NocturneTheme.purpleBright : Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .foregroundColor(selectedFilterBookId == book.id ? .white : Color.white.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Notes Grid (Apple Notes Style)
    private var notesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            ForEach(filteredNotes) { note in
                Button(action: {
                    selectedNoteForDetail = note
                }) {
                    AppleNotePhotoCard(note: note)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Empty Placeholder
    private var emptyNotesPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 48))
                .foregroundColor(NocturneTheme.purpleBright.opacity(0.6))
            
            Text("No Reading Notes Snapped Yet")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Point your camera at highlighted book passages or notebook diagrams, snap, and add your daily summary reflection.")
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button(action: startCameraCapture) {
                HStack(spacing: 6) {
                    Image(systemName: "camera.fill")
                    Text("Snap First Photo Note")
                }
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(NocturneTheme.purplePrimary)
                        .overlay(Capsule().stroke(NocturneTheme.purpleBright, lineWidth: 1))
                )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .liquidCard(cornerRadius: 20)
    }
}

// MARK: - Apple Note Photo Card (Simulates Apple Notes Gallery appearance with Summary)
public struct AppleNotePhotoCard: View {
    let note: DailyPhotoNote
    @ObservedObject private var dataManager = DataManager.shared
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Photo Preview Frame
            ZStack(alignment: .topTrailing) {
                if let firstImgName = note.allImages.first, let uiImage = dataManager.loadImage(fileName: firstImgName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(3/4, contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(NocturneTheme.bgSurfaceElevated)
                        .frame(height: 160)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white.opacity(0.3))
                        )
                }
                
                VStack(alignment: .trailing, spacing: 4) {
                    if note.allImages.count > 1 {
                        HStack(spacing: 3) {
                            Image(systemName: "photo.stack")
                                .font(.system(size: 9))
                            Text("\(note.allImages.count)")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.75))
                        .clipShape(Capsule())
                        .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 3) {
                        Image(systemName: note.isCloudSynced ? "icloud.fill" : "arrow.triangle.2.circlepath.icloud.fill")
                            .font(.system(size: 10))
                        Text(note.isCloudSynced ? "Cloud" : "Syncing")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.7))
                    .clipShape(Capsule())
                    .foregroundColor(note.isCloudSynced ? .cyan : .yellow)
                }
                .padding(8)
            }
            
            // Note Meta & Summary preview
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    if let topic = note.dominantTopic {
                        Circle()
                            .fill(topic.accentColor)
                            .frame(width: 6, height: 6)
                    }
                    
                    Text(note.bookTitle)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                
                if let summary = note.summaryText, !summary.isEmpty {
                    Text(summary)
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.85))
                        .lineLimit(2)
                        .padding(.vertical, 1)
                }
                
                HStack {
                    if let pageDesc = note.pageRangeDescription {
                        Text(pageDesc)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(NocturneTheme.purpleBright)
                    }
                    
                    Spacer()
                    
                    Text(note.timestamp, style: .date)
                        .font(.system(size: 10))
                        .foregroundColor(Color.white.opacity(0.45))
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 6)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(NocturneTheme.bgSurface.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 3)
        )
    }
}

// MARK: - Zoomable Photo Note Sheet
public struct ZoomablePhotoNoteSheet: View {
    let note: DailyPhotoNote
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingDeleteConfirm: Bool = false
    @State private var selectedImageIndex: Int = 0
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Photo Display (TabView Carousel if multiple)
                    if note.allImages.count > 1 {
                        TabView(selection: $selectedImageIndex) {
                            ForEach(note.allImages.indices, id: \.self) { idx in
                                if let uiImage = dataManager.loadImage(fileName: note.allImages[idx]) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .tag(idx)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .padding()
                                }
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let firstImg = note.allImages.first, let uiImage = dataManager.loadImage(fileName: firstImg) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .black.opacity(0.6), radius: 16)
                            .padding()
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    // Note Info Bar & Summary
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.bookTitle)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 8) {
                                    if let pageDesc = note.pageRangeDescription {
                                        Text(pageDesc)
                                            .font(.subheadline.bold())
                                            .foregroundColor(NocturneTheme.purpleBright)
                                    }
                                    
                                    Text("•")
                                        .foregroundColor(.white.opacity(0.4))
                                    
                                    Text(note.timestamp, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    Text("•")
                                        .foregroundColor(.white.opacity(0.4))
                                    
                                    HStack(spacing: 3) {
                                        Image(systemName: "icloud.fill")
                                        Text("Cloud Backup")
                                    }
                                    .font(.caption.bold())
                                    .foregroundColor(.cyan)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        if let summary = note.summaryText, !summary.isEmpty {
                            Divider().background(Color.white.opacity(0.15))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("DAILY SUMMARY")
                                    .font(.caption2.bold())
                                    .foregroundColor(Color.white.opacity(0.5))
                                    .tracking(1.2)
                                
                                Text(summary)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .lineSpacing(3)
                            }
                        }
                    }
                    .padding()
                    .liquidCard(cornerRadius: 16)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
            .navigationTitle("Reading Note Photo")
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingDeleteConfirm = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.red.opacity(0.15)))
                    }
                    .buttonStyle(.plain)
                }
            }
            .confirmationDialog("Delete this note?", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                Button("Delete Photo Note", role: .destructive) {
                    dataManager.deletePhotoNote(note)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

// MARK: - Assign Book Sheet
public struct AssignBookToNoteSheet: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    var onSelectBook: (Book) -> Void
    
    public var body: some View {
        NavigationStack {
            ZStack {
                NocturneTheme.bgVoid.ignoresSafeArea()
                
                List {
                    ForEach(dataManager.books) { book in
                        Button(action: {
                            onSelectBook(book)
                        }) {
                            HStack(spacing: 12) {
                                BookCoverView(book: book, width: 44, height: 60, cornerRadius: 6)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(book.title)
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                    Text(book.author)
                                        .font(.caption)
                                        .foregroundColor(Color.white.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                Text("\(book.currentPage)/\(book.totalPages) pp.")
                                    .font(.caption.monospaced())
                                    .foregroundColor(NocturneTheme.purpleBright)
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(NocturneTheme.bgSurface)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Select Book For Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.white.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
