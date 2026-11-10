import SwiftUI

public struct AddCustomBookSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    
    @State private var searchTitle: String = ""
    @State private var isSearching: Bool = false
    @State private var discoveredBook: DiscoveredBookInfo? = nil
    @State private var searchErrorMessage: String? = nil
    
    // Editable fields once found or manual
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var totalPagesText: String = ""
    @State private var topic1: String = ""
    @State private var topic2: String = ""
    @State private var keyInsight: String = ""
    @State private var coverImageData: Data? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                NocturneTheme.bgVoid.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // AI Smart Search Box
                        aiSearchCard
                        
                        // Result Preview / Manual Details Editor
                        if isSearching {
                            searchingIndicator
                        } else if !title.isEmpty || discoveredBook != nil {
                            bookDetailsForm
                        } else {
                            helperHintView
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add Extra Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                }
                
                if !title.isEmpty && (Int(totalPagesText) ?? 0) > 0 {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save Book") { saveBook() }
                            .font(.headline.bold())
                            .foregroundColor(NocturneTheme.purpleBright)
                    }
                }
            }
        }
    }
    
    // MARK: - AI Search Bar Card
    private var aiSearchCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundColor(NocturneTheme.purpleBright)
                Text("AI AUTOMATIC BOOK LOOKUP")
                    .font(.caption.bold())
                    .foregroundColor(Color.white.opacity(0.6))
                    .tracking(1.2)
            }
            
            HStack(spacing: 10) {
                TextField("e.g. A technique for producing ideas", text: $searchTitle)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .submitLabel(.search)
                    .onSubmit {
                        performAISearch()
                    }
                
                Button(action: performAISearch) {
                    HStack(spacing: 4) {
                        Image(systemName: "wand.and.stars")
                        Text("Search")
                    }
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().fill(NocturneTheme.purplePrimary)
                    )
                    .foregroundColor(.white)
                }
                .disabled(searchTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(NocturneTheme.bgSurfaceElevated)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
            )
            
            if let error = searchErrorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(16)
        .liquidCard(cornerRadius: 16)
    }
    
    // MARK: - Searching Indicator
    private var searchingIndicator: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(NocturneTheme.purpleBright)
                .scaleEffect(1.2)
            
            Text("AI is querying OpenLibrary, fetching verified cover & classifying core topics...")
                .font(.footnote)
                .foregroundColor(Color.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .liquidCard(cornerRadius: 16)
    }
    
    // MARK: - Book Details Form
    private var bookDetailsForm: some View {
        VStack(spacing: 16) {
            // Book Cover Preview & Title/Author
            HStack(alignment: .top, spacing: 16) {
                // Cover Thumbnail
                ZStack {
                    if let data = coverImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 90, height: 130)
                            .clipped()
                            .cornerRadius(10)
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(colors: [Color(hex: "#1e293b"), Color(hex: "#334155")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 90, height: 130)
                            .overlay(
                                VStack(spacing: 4) {
                                    Image(systemName: "book.closed")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.4))
                                    Text("No Cover")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            )
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.5), radius: 6)
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("BOOK TITLE")
                            .font(.caption2.bold())
                            .foregroundColor(Color.white.opacity(0.5))
                        TextField("Title", text: $title)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AUTHOR")
                            .font(.caption2.bold())
                            .foregroundColor(Color.white.opacity(0.5))
                        TextField("Author", text: $author)
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TOTAL PAGES")
                            .font(.caption2.bold())
                            .foregroundColor(Color.white.opacity(0.5))
                        TextField("Pages", text: $totalPagesText)
                            .keyboardType(.numberPad)
                            .font(.subheadline.bold())
                            .foregroundColor(NocturneTheme.purpleBright)
                    }
                }
            }
            .padding(16)
            .liquidCard(cornerRadius: 16)
            
            // AI Extracted Topics (1 or 2)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.teal)
                    Text("AI CLASSIFIED TOPICS")
                        .font(.caption.bold())
                        .foregroundColor(Color.white.opacity(0.6))
                        .tracking(1.1)
                }
                
                HStack(spacing: 10) {
                    TextField("Primary Topic", text: $topic1)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.teal.opacity(0.15))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.teal.opacity(0.4), lineWidth: 1))
                        )
                    
                    TextField("Secondary Topic", text: $topic2)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.purple.opacity(0.15))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.purple.opacity(0.4), lineWidth: 1))
                        )
                }
            }
            .padding(16)
            .liquidCard(cornerRadius: 16)
            
            // Core Focus / Insight
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "quote.opening")
                        .foregroundColor(NocturneTheme.purpleBright)
                    Text("CORE FOCUS & KEY INSIGHT")
                        .font(.caption.bold())
                        .foregroundColor(Color.white.opacity(0.6))
                        .tracking(1.1)
                }
                
                TextField("Key Insight...", text: $keyInsight, axis: .vertical)
                    .lineLimit(3...5)
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.85))
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(NocturneTheme.bgSurfaceElevated)
                    )
            }
            .padding(16)
            .liquidCard(cornerRadius: 16)
            
            // Save Button
            Button(action: saveBook) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add to Extra Books")
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
    
    // MARK: - Helper Hint
    private var helperHintView: some View {
        VStack(spacing: 12) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 38))
                .foregroundColor(NocturneTheme.purpleBright)
            
            Text("Type any book title above")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Shelfwise AI will fetch the exact book cover, calculate the page count, and determine the 1 or 2 core dominant focus topics.")
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .liquidCard(cornerRadius: 16)
    }
    
    // MARK: - Search Action
    private func performAISearch() {
        let q = searchTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        
        isSearching = true
        searchErrorMessage = nil
        
        Task {
            if let result = await BookLookupService.shared.fetchBookDetails(query: q) {
                await MainActor.run {
                    self.discoveredBook = result
                    self.title = result.title
                    self.author = result.author
                    self.totalPagesText = "\(result.totalPages)"
                    self.keyInsight = result.keyInsight
                    self.topic1 = result.topics.first ?? "Creative Thinking"
                    self.topic2 = result.topics.count > 1 ? result.topics[1] : ""
                    self.coverImageData = result.coverImageData
                    self.isSearching = false
                }
            } else {
                await MainActor.run {
                    self.searchErrorMessage = "Could not find book online. You can enter details manually below."
                    self.title = q
                    self.totalPagesText = "200"
                    self.topic1 = "Creative Thinking"
                    self.isSearching = false
                }
            }
        }
    }
    
    private func saveBook() {
        let pages = Int(totalPagesText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 100
        var topics: [String] = []
        let t1 = topic1.trimmingCharacters(in: .whitespacesAndNewlines)
        let t2 = topic2.trimmingCharacters(in: .whitespacesAndNewlines)
        if !t1.isEmpty { topics.append(t1) }
        if !t2.isEmpty { topics.append(t2) }
        
        _ = dataManager.addPersonalBook(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            author: author.trimmingCharacters(in: .whitespacesAndNewlines),
            totalPages: pages,
            currentPage: 0,
            status: .wantToRead,
            keyInsight: keyInsight.trimmingCharacters(in: .whitespacesAndNewlines),
            customTopics: topics,
            coverData: coverImageData
        )
        dismiss()
    }
}
