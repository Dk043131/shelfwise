import SwiftUI

public struct ExtraBooksView: View {
    @ObservedObject private var dataManager = DataManager.shared
    
    @State private var showingAddSheet: Bool = false
    @State private var selectedStatusFilter: ReadingStatus = .reading
    @State private var searchQuery: String = ""
    @State private var bookForDetail: Book? = nil
    @State private var bookToLogPages: Book? = nil
    @State private var bookToDelete: Book? = nil
    @State private var showingDeleteAlert: Bool = false
    
    public init() {}
    
    private var filteredExtraBooks: [Book] {
        dataManager.myPersonalBooks.filter { book in
            // Status filter
            let matchesStatus: Bool
            switch selectedStatusFilter {
            case .all: matchesStatus = true
            case .reading: matchesStatus = (book.status == .reading)
            case .completed: matchesStatus = (book.status == .completed)
            case .wantToRead: matchesStatus = (book.status == .wantToRead)
            }
            
            // Search
            let matchesSearch: Bool
            if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                matchesSearch = true
            } else {
                let q = searchQuery.lowercased()
                matchesSearch = book.title.lowercased().contains(q)
                    || book.author.lowercased().contains(q)
                    || book.customTopics.contains { $0.lowercased().contains(q) }
            }
            
            return matchesStatus && matchesSearch
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                NocturneTheme.bgVoid.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Header Stats Card
                        statsCard
                        
                        // Search bar
                        searchBar
                        
                        // Filter Pills
                        statusFilterTabs
                        
                        // Books List or Empty State
                        if filteredExtraBooks.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(filteredExtraBooks) { book in
                                    BookCardView(
                                        book: book,
                                        onLogPages: {
                                            self.bookToLogPages = book
                                        },
                                        onOpenDetail: {
                                            self.bookForDetail = book
                                        }
                                    )
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            bookToDelete = book
                                            showingDeleteAlert = true
                                        } label: {
                                            Label("Remove Book", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }
                .scrollDismissesKeyboard(.interactively)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                )
            }
            .navigationTitle("Extra Books")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 6) {
                        Image(systemName: "books.vertical")
                            .foregroundColor(NocturneTheme.purpleBright)
                        Text("My Shelf")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .bold))
                            Text("Add Book")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(NocturneTheme.purplePrimary))
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddCustomBookSheet()
            }
            .sheet(item: $bookForDetail) { book in
                if let index = dataManager.books.firstIndex(where: { $0.id == book.id }) {
                    BookDetailView(book: $dataManager.books[index])
                }
            }
            .sheet(item: $bookToLogPages) { book in
                if let index = dataManager.books.firstIndex(where: { $0.id == book.id }) {
                    LogPagesSheet(book: $dataManager.books[index])
                }
            }
            .alert("Remove Book", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let b = bookToDelete {
                        dataManager.deletePersonalBook(b)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to remove \"\(bookToDelete?.title ?? "")\" from your personal reading shelf?")
            }
        }
    }
    
    // MARK: - Stats Card
    private var statsCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.teal)
                    Text("PERSONAL READING LIST")
                        .font(.caption2.bold())
                        .foregroundColor(.teal)
                        .tracking(1.1)
                }
                
                Text("Non-Curriculum Library")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(dataManager.myPersonalBooks.filter { $0.isCompleted }.count)/\(dataManager.myPersonalBooks.count) Done")
                    .font(.caption.bold())
                    .foregroundColor(.teal)
                
                let read = dataManager.myPersonalBooks.reduce(0) { $0 + $1.currentPage }
                Text("\(read) pages read")
                    .font(.caption2)
                    .foregroundColor(Color.white.opacity(0.6))
            }
        }
        .padding(14)
        .liquidCard(cornerRadius: 16)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.white.opacity(0.45))
            
            TextField("Search my extra books...", text: $searchQuery)
                .font(.subheadline)
                .foregroundColor(.white)
            
            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.white.opacity(0.45))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(NocturneTheme.bgSurface.opacity(0.85))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.10), lineWidth: 1))
        )
    }
    
    // MARK: - Status Filter Tabs
    private var statusFilterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ReadingStatus.allCases) { status in
                    let isSelected = (selectedStatusFilter == status)
                    Button(action: {
                        withAnimation { selectedStatusFilter = status }
                    }) {
                        Text(status.rawValue)
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule().fill(isSelected ? NocturneTheme.purplePrimary : Color.white.opacity(0.06))
                            )
                            .overlay(
                                Capsule().stroke(isSelected ? NocturneTheme.purpleBright : Color.white.opacity(0.12), lineWidth: 1)
                            )
                            .foregroundColor(isSelected ? .white : Color.white.opacity(0.65))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "books.vertical.circle")
                .font(.system(size: 48))
                .foregroundColor(NocturneTheme.purpleBright.opacity(0.6))
            
            Text("No Extra Books Yet")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Keep your personal reading list separate from the 10-level psychology curriculum.\n\nTap '+ Add Book', type a title like 'A technique for producing ideas', and AI will auto-fetch the thumbnail cover, page count, and key topics.")
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Button(action: { showingAddSheet = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Your First Book")
                }
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Capsule().fill(NocturneTheme.purplePrimary))
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .liquidCard(cornerRadius: 18)
    }
}
