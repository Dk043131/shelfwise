import SwiftUI
import PhotosUI

public struct LogPagesSheet: View {
    @Binding var book: Book
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    
    // Additional pages read today (default 0 or 1)
    @State private var additionalPages: Int = 1
    
    // Multi-image capture and photo picker state
    @State private var capturedImages: [PlatformImage] = []
    @State private var showingCamera: Bool = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var noteSummary: String = ""
    @State private var showingAlreadyLoggedAlert: Bool = false
    
    public init(book: Binding<Book>) {
        self._book = book
    }
    
    private var isAlreadyLoggedToday: Bool {
        dataManager.hasLoggedToday(for: book.id)
    }
    
    private var remainingPagesInBook: Int {
        max(0, book.totalPages - book.currentPage)
    }
    
    private var calculatedNewCurrentPage: Int {
        min(book.totalPages, book.currentPage + additionalPages)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                NocturneTheme.bgVoid.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Already Logged Warning Banner
                        if isAlreadyLoggedToday {
                            alreadyLoggedBanner
                        }
                        
                        // Book Header Preview
                        bookHeader
                        
                        // Stepper Card for Additional Pages
                        additionalPagesStepperCard
                        
                        // Multi-Photo Proof & Daily Note Capture
                        imagesAttachmentCard
                        
                        // Notes / Thoughts Field
                        summaryCard
                        
                        // Save Button
                        saveButton
                    }
                    .padding(20)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Log Reading")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismissKeyboard()
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                            Text("Cancel")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            dismissKeyboard()
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(NocturneTheme.purpleBright)
                    }
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView { capturedImage in
                    capturedImages.append(capturedImage)
                }
            }
            .onChange(of: selectedPhotoItems) { newItems in
                Task {
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let img = PlatformImage(data: data) {
                            await MainActor.run {
                                capturedImages.append(img)
                            }
                        }
                    }
                    await MainActor.run {
                        selectedPhotoItems.removeAll()
                    }
                }
            }
            .alert("Already Logged Today", isPresented: $showingAlreadyLoggedAlert) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("You have already logged your reading session for \"\(book.title)\" today! You can log your next progress tomorrow.")
            }
        }
    }
    
    // MARK: - Already Logged Warning
    private var alreadyLoggedBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title2)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Session Already Logged Today")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text("Only 1 log per day is allowed for each book to maintain authentic reading habit discipline.")
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.75))
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.green.opacity(0.18))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.green.opacity(0.4), lineWidth: 1))
        )
    }
    
    // MARK: - Book Header Preview
    private var bookHeader: some View {
        HStack(spacing: 14) {
            BookCoverView(book: book, width: 66, height: 94, cornerRadius: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(book.author)
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.6))
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text("\(book.currentPage) / \(book.totalPages) pages")
                        .font(.caption.bold())
                        .foregroundColor(Color.white.opacity(0.85))
                    
                    Text("•")
                        .foregroundColor(Color.white.opacity(0.4))
                    
                    Text("\(book.progressPercentage)%")
                        .font(.caption.bold())
                        .foregroundColor(NocturneTheme.purpleBright)
                }
                .padding(.top, 2)
            }
            Spacer()
        }
        .padding(14)
        .liquidCard(cornerRadius: 16)
    }
    
    // MARK: - Additional Pages Stepper Card
    private var additionalPagesStepperCard: some View {
        VStack(spacing: 16) {
            Text("HOW MANY PAGES DID YOU READ TODAY?")
                .font(.caption2.bold())
                .foregroundColor(Color.white.opacity(0.55))
                .tracking(1.1)
            
            // Large Stepper Row with - and + buttons
            HStack(spacing: 24) {
                // Minus Button
                Button(action: {
                    dismissKeyboard()
                    if additionalPages > 1 {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            additionalPages -= 1
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 52, height: 52)
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        
                        Image(systemName: "minus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(additionalPages <= 1 ? Color.white.opacity(0.3) : .white)
                    }
                }
                .disabled(additionalPages <= 1 || isAlreadyLoggedToday)
                .buttonStyle(.plain)
                
                // Display Additional Pages
                VStack(spacing: 2) {
                    Text("+\(additionalPages)")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundColor(NocturneTheme.purpleBright)
                    
                    Text(additionalPages == 1 ? "page today" : "pages today")
                        .font(.caption.bold())
                        .foregroundColor(Color.white.opacity(0.6))
                }
                .frame(minWidth: 110)
                
                // Plus Button
                Button(action: {
                    dismissKeyboard()
                    if calculatedNewCurrentPage < book.totalPages {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            additionalPages += 1
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(NocturneTheme.purplePrimary.opacity(0.8))
                            .frame(width: 52, height: 52)
                            .overlay(Circle().stroke(NocturneTheme.purpleBright, lineWidth: 1))
                        
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(calculatedNewCurrentPage >= book.totalPages || isAlreadyLoggedToday)
                .buttonStyle(.plain)
            }
            
            // Visual dynamic calculation: e.g. 5/61 -> 11/61
            HStack(spacing: 8) {
                Text("\(book.currentPage) / \(book.totalPages)")
                    .font(.subheadline.bold())
                    .foregroundColor(Color.white.opacity(0.6))
                
                Image(systemName: "arrow.right")
                    .font(.caption.bold())
                    .foregroundColor(NocturneTheme.purpleBright)
                
                Text("\(calculatedNewCurrentPage) / \(book.totalPages)")
                    .font(.subheadline.bold())
                    .foregroundColor(calculatedNewCurrentPage >= book.totalPages ? .green : .white)
                
                Spacer()
                
                Text("\(remainingPagesInBook - additionalPages) left")
                    .font(.caption.bold())
                    .foregroundColor(Color.white.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.04))
            )
            
            // Quick increments: +5, +10, +20, +50
            HStack(spacing: 8) {
                ForEach([5, 10, 20, 30], id: \.self) { amt in
                    Button("+\(amt)") {
                        dismissKeyboard()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            let available = book.totalPages - book.currentPage
                            additionalPages = min(available, additionalPages + amt)
                        }
                    }
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.08))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12), lineWidth: 1))
                    )
                    .foregroundColor(.white)
                    .disabled(isAlreadyLoggedToday)
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .liquidCard(cornerRadius: 18)
    }
    
    // MARK: - Multi-Photo Attachment Card
    private var imagesAttachmentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "camera.fill")
                    .foregroundColor(NocturneTheme.purpleBright)
                Text("ATTACH DAILY READING PROOF / NOTES")
                    .font(.caption2.bold())
                    .foregroundColor(Color.white.opacity(0.6))
                    .tracking(1.1)
                
                Spacer()
                
                if !capturedImages.isEmpty {
                    Text("\(capturedImages.count) \(capturedImages.count == 1 ? "photo" : "photos")")
                        .font(.caption2.bold())
                        .foregroundColor(NocturneTheme.purpleBright)
                }
            }
            
            // Thumbnail Strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // Snap with Camera button
                    Button(action: {
                        dismissKeyboard()
                        showingCamera = true
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "camera")
                                .font(.title3)
                            Text("Camera")
                                .font(.caption2.bold())
                        }
                        .foregroundColor(.white)
                        .frame(width: 72, height: 86)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(NocturneTheme.purplePrimary.opacity(0.3))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(NocturneTheme.purpleBright.opacity(0.6), lineWidth: 1))
                        )
                    }
                    .disabled(isAlreadyLoggedToday)
                    .buttonStyle(.plain)
                    
                    // Choose from Photos button
                    PhotosPicker(
                        selection: $selectedPhotoItems,
                        maxSelectionCount: 6,
                        matching: .images
                    ) {
                        VStack(spacing: 4) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title3)
                            Text("Photos")
                                .font(.caption2.bold())
                        }
                        .foregroundColor(.white)
                        .frame(width: 72, height: 86)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.08))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.15), lineWidth: 1))
                        )
                    }
                    .disabled(isAlreadyLoggedToday)
                    .buttonStyle(.plain)
                    
                    // Display Captured Images with delete button
                    ForEach(Array(capturedImages.enumerated()), id: \.offset) { index, img in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 72, height: 86)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            
                            Button(action: {
                                withAnimation {
                                    capturedImages.remove(at: index)
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black))
                            }
                            .offset(x: 4, y: -4)
                        }
                    }
                }
            }
        }
        .padding(16)
        .liquidCard(cornerRadius: 16)
    }
    
    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(Color.white.opacity(0.6))
                Text("DAILY READING SUMMARY / THOUGHTS")
                    .font(.caption2.bold())
                    .foregroundColor(Color.white.opacity(0.55))
                    .tracking(1.1)
            }
            
            TextField("Key takeaway or note from today's pages...", text: $noteSummary, axis: .vertical)
                .lineLimit(2...4)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(NocturneTheme.bgSurfaceElevated)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.12), lineWidth: 1))
                )
        }
        .padding(16)
        .liquidCard(cornerRadius: 16)
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: saveProgress) {
            HStack(spacing: 8) {
                Image(systemName: isAlreadyLoggedToday ? "checkmark.seal.fill" : "checkmark.circle.fill")
                    .font(.headline)
                Text(isAlreadyLoggedToday ? "Already Logged for Today" : "Log +\(additionalPages) Pages Today")
                    .font(.headline.weight(.semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isAlreadyLoggedToday ? Color.gray.opacity(0.3) : NocturneTheme.purplePrimary)
            )
        }
        .disabled(isAlreadyLoggedToday || additionalPages <= 0)
        .buttonStyle(.plain)
        .padding(.top, 4)
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func saveProgress() {
        dismissKeyboard()
        
        guard !isAlreadyLoggedToday else {
            showingAlreadyLoggedAlert = true
            return
        }
        
        let startPage = book.currentPage
        let endPage = calculatedNewCurrentPage
        
        // 1. If images are attached, create the daily photo note
        if !capturedImages.isEmpty {
            dataManager.addPhotoNotes(
                images: capturedImages,
                book: book,
                fromPage: startPage,
                toPage: endPage,
                summaryText: noteSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : noteSummary
            )
        }
        
        // 2. Log reading session (guaranteed 1 per day)
        dataManager.logReadingSession(
            bookId: book.id,
            pagesRead: additionalPages,
            notesSummary: noteSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : noteSummary
        )
        
        dismiss()
    }
}
