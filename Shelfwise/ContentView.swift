import SwiftUI
import PhotosUI

public enum AppTab: String, CaseIterable, Identifiable {
    case library = "Library"
    case extraBooks = "Extra Books"
    case photoNotes = "Photo Notes"
    case curriculum = "Curriculum"
    case weeklyReport = "Weekly Report"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .library: return "books.vertical.fill"
        case .extraBooks: return "plus.rectangle.on.rectangle"
        case .photoNotes: return "photo.on.rectangle.angled"
        case .curriculum: return "brain.head.profile"
        case .weeklyReport: return "chart.bar.xaxis"
        }
    }
}

public struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var selectedTab: AppTab = .library
    @State private var searchQuery: String = ""
    @State private var selectedStatusFilter: ReadingStatus = .reading
    @State private var selectedTopicFilter: PsychologyTopic? = nil
    
    // Sheet States
    @State private var bookToLogPages: Book? = nil
    @State private var bookForDetail: Book? = nil
    @State private var quickSnapPhotoItem: PhotosPickerItem? = nil
    
    public init() {}
    
    // Filtered books
    private var filteredBooks: [Book] {
        dataManager.books.filter { book in
            guard book.isCurriculumBook else { return false }
            // Status filter
            let matchesStatus: Bool
            switch selectedStatusFilter {
            case .all: matchesStatus = true
            case .reading: matchesStatus = (book.status == .reading)
            case .completed: matchesStatus = (book.status == .completed)
            case .wantToRead: matchesStatus = (book.status == .wantToRead)
            }
            
            // Topic filter
            let matchesTopic: Bool
            if let topic = selectedTopicFilter {
                matchesTopic = book.dominantTopics.contains(topic)
            } else {
                matchesTopic = true
            }
            
            // Search query
            let matchesSearch: Bool
            if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                matchesSearch = true
            } else {
                let query = searchQuery.lowercased()
                matchesSearch = book.title.lowercased().contains(query)
                    || book.author.lowercased().contains(query)
                    || book.dominantTopics.contains { $0.rawValue.lowercased().contains(query) }
            }
            
            return matchesStatus && matchesTopic && matchesSearch
        }
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content Area by Tab
            Group {
                switch selectedTab {
                case .library:
                    libraryView
                case .extraBooks:
                    ExtraBooksView()
                case .photoNotes:
                    PhotoNotesView()
                case .curriculum:
                    CurriculumView()
                case .weeklyReport:
                    WeeklyReportView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            )
            
            // Floating Apple Liquid Glass Bottom Navigation Bar
            floatingTabBar
        }
        .preferredColorScheme(.dark)
        .sheet(item: $bookToLogPages) { book in
            if let index = dataManager.books.firstIndex(where: { $0.id == book.id }) {
                LogPagesSheet(book: $dataManager.books[index])
            }
        }
        .sheet(item: $bookForDetail) { book in
            if let index = dataManager.books.firstIndex(where: { $0.id == book.id }) {
                BookDetailView(book: $dataManager.books[index])
            }
        }
    }
    
    // MARK: - Library View (Inspired by Shelfwise + iPhone Liquid Buttons)
    private var libraryView: some View {
        NavigationStack {
            ZStack {
                NocturneTheme.bgVoid.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Header Stats Bar
                        headerStatsBar
                        
                        // Search Bar
                        searchBar
                        
                        // Status Filter Tabs
                        statusFilterTabs
                        
                        // Dominant Topic Filter Scroll
                        topicFilterScroll
                        
                        // Books List
                        if filteredBooks.isEmpty {
                            emptyBooksState
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredBooks) { book in
                                    BookCardView(
                                        book: book,
                                        onLogPages: {
                                            bookToLogPages = book
                                        },
                                        onOpenDetail: {
                                            bookForDetail = book
                                        },
                                        onTopicTap: { topic in
                                            withAnimation {
                                                if selectedTopicFilter == topic {
                                                    selectedTopicFilter = nil
                                                } else {
                                                    selectedTopicFilter = topic
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 95) // space for floating bottom bar
                }
            }
            .navigationTitle("Shelfwise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 6) {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(NocturneTheme.purpleBright)
                        Text("Level 1")
                            .font(.caption.bold())
                            .foregroundColor(NocturneTheme.purpleBright)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(NocturneTheme.purplePrimary.opacity(0.2)))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(dataManager.currentStreakDays)d")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.orange.opacity(0.2)))
                }
            }
        }
    }
    
    // MARK: - Header Stats Bar
    private var headerStatsBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("DARK PSYCHOLOGY CURRICULUM")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.5))
                    .tracking(1.1)
                
                Text("Level 1: Understanding the Mind")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(dataManager.completedBooksCount)/13 Done")
                    .font(.caption.bold())
                    .foregroundColor(NocturneTheme.purpleBright)
                
                Text("\(dataManager.overallLevel1ProgressPercent)% Mastered")
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
            
            TextField("Search books, authors, or topics...", text: $searchQuery)
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
    
    // MARK: - Status Filter Tabs (All, Reading, Completed, Want to Read)
    private var statusFilterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ReadingStatus.allCases) { status in
                    let isSelected = (selectedStatusFilter == status)
                    let count: Int = {
                        let cBooks = dataManager.curriculumBooks
                        switch status {
                        case .all: return cBooks.count
                        case .reading: return cBooks.filter { $0.status == .reading }.count
                        case .completed: return cBooks.filter { $0.status == .completed }.count
                        case .wantToRead: return cBooks.filter { $0.status == .wantToRead }.count
                        }
                    }()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedStatusFilter = status
                        }
                    }) {
                        HStack(spacing: 5) {
                            Text(status.rawValue)
                                .font(.caption.bold())
                            Text("(\(count))")
                                .font(.caption2)
                                .opacity(0.8)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            Capsule().fill(isSelected ? NocturneTheme.purplePrimary.opacity(0.3) : Color.white.opacity(0.06))
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
    
    // MARK: - Topic Filter Scroll
    private var topicFilterScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All Topics" Pill
                Button(action: {
                    withAnimation { selectedTopicFilter = nil }
                }) {
                    Text("All Topics")
                        .font(.caption2.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(selectedTopicFilter == nil ? Color.white.opacity(0.2) : Color.white.opacity(0.04)))
                        .overlay(Capsule().stroke(selectedTopicFilter == nil ? Color.white.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1))
                        .foregroundColor(selectedTopicFilter == nil ? .white : Color.white.opacity(0.5))
                }
                .buttonStyle(.plain)
                
                // 10 Topics Pills
                ForEach(PsychologyTopic.allCases) { topic in
                    let isSelected = (selectedTopicFilter == topic)
                    Button(action: {
                        withAnimation {
                            if selectedTopicFilter == topic {
                                selectedTopicFilter = nil
                            } else {
                                selectedTopicFilter = topic
                            }
                        }
                    }) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(topic.accentColor)
                                .frame(width: 6, height: 6)
                            Text(topic.shortName)
                                .font(.caption2.bold())
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(isSelected ? topic.accentColor.opacity(0.25) : Color.white.opacity(0.04))
                        )
                        .overlay(
                            Capsule().stroke(isSelected ? topic.accentColor : Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .foregroundColor(isSelected ? .white : Color.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Empty Filter State
    private var emptyBooksState: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.closed")
                .font(.system(size: 40))
                .foregroundColor(Color.white.opacity(0.3))
            Text("No books found matching criteria")
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.6))
            Button("Reset Filters") {
                selectedStatusFilter = .all
                selectedTopicFilter = nil
                searchQuery = ""
            }
            .buttonStyle(.glass)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .liquidCard(cornerRadius: 18)
    }
    
    // MARK: - Floating Apple Liquid Glass Bottom Navigation Bar
    private var floatingTabBar: some View {
        GlassEffectContainer(spacing: 10) {
            HStack(spacing: 8) {
                ForEach(AppTab.allCases) { tab in
                    let isSelected = (selectedTab == tab)
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 18, weight: isSelected ? .bold : .regular))
                            Text(tab.rawValue)
                                .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundColor(isSelected ? NocturneTheme.purpleBright : Color.white.opacity(0.55))
                    }
                    .buttonStyle(.glass)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(red: 0.08, green: 0.09, blue: 0.16).opacity(0.92))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.6), radius: 18, x: 0, y: 8)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }
}

#Preview {
    ContentView()
}
