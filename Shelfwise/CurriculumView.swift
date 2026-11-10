import SwiftUI

public struct CurriculumView: View {
    @ObservedObject private var dataManager = DataManager.shared
    
    @State private var showingLevelSelector: Bool = false
    @State private var selectedTopicForFilter: PsychologyTopic? = nil
    @State private var selectedBookForDetail: Book? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                NocturneTheme.bgVoid.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Level 1 Master Banner
                        levelHeaderBanner
                        
                        // Level 1 Topics Explorer Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("LEVEL 1 PSYCHOLOGICAL DOMAINS")
                                    .font(.caption.bold())
                                    .foregroundColor(Color.white.opacity(0.5))
                                    .tracking(1.2)
                                Text("10 Cognitive & Behavioural Pillars")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        
                        // 10 Topics Grid / List
                        VStack(spacing: 14) {
                            ForEach(PsychologyTopic.allCases) { topic in
                                topicCard(for: topic)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 90) // space for floating bottom bar
                }
            }
            .navigationTitle("Curriculum")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingLevelSelector = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.stack.3d.up.fill")
                            Text("All 10 Levels")
                                .font(.caption.bold())
                        }
                    }
                    .buttonStyle(.glass)
                }
            }
            .sheet(isPresented: $showingLevelSelector) {
                LevelSelectorSheet()
            }
            .sheet(item: $selectedBookForDetail) { book in
                if let index = dataManager.books.firstIndex(where: { $0.id == book.id }) {
                    BookDetailView(book: $dataManager.books[index])
                }
            }
        }
    }
    
    // MARK: - Level 1 Banner
    private var levelHeaderBanner: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(NocturneTheme.purpleBright)
                    Text("CURRENT ACTIVE LEVEL")
                        .font(.caption2.bold())
                        .foregroundColor(NocturneTheme.purpleBright)
                        .tracking(1.1)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(NocturneTheme.purplePrimary.opacity(0.2)))
                
                Spacer()
                
                Button(action: { showingLevelSelector = true }) {
                    HStack(spacing: 4) {
                        Text("Level 1 of 10")
                            .font(.caption.bold())
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                }
                .buttonStyle(.glass)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Level 1 — Understanding the Human Mind")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text("The foundation of everything. Deconstruct cognitive biases, subconscious reflexes, and decision heuristics before advancing.")
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.75))
                    .lineSpacing(3)
            }
            
            // Progress Bar for Level 1
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(dataManager.completedBooksCount) of 13 Books Completed")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(dataManager.completedLevel1Pages) / \(dataManager.totalLevel1Pages) pp. (\(dataManager.overallLevel1ProgressPercent)%)")
                        .font(.caption.bold())
                        .foregroundColor(NocturneTheme.purpleBright)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 7)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [NocturneTheme.purpleBright, Color.cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(7, geo.size.width * CGFloat(dataManager.overallLevel1ProgressPercent) / 100.0), height: 7)
                    }
                }
                .frame(height: 7)
            }
            .padding(.top, 4)
        }
        .padding(18)
        .liquidCard(cornerRadius: 20)
    }
    
    // MARK: - Topic Card
    @ViewBuilder
    private func topicCard(for topic: PsychologyTopic) -> some View {
        let matchingBooks = dataManager.books.filter { $0.dominantTopics.contains(topic) }
        let totalTopicPages = matchingBooks.reduce(0) { $0 + $1.totalPages }
        let completedTopicPages = matchingBooks.reduce(0) { $0 + $1.currentPage }
        let topicPercent = totalTopicPages > 0 ? Int((Double(completedTopicPages) / Double(totalTopicPages)) * 100) : 0
        
        VStack(alignment: .leading, spacing: 12) {
            // Header with number and icon
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(topic.accentColor.opacity(0.2))
                        .frame(width: 38, height: 38)
                    Image(systemName: topic.systemIcon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(topic.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("\(topic.topicNumber). \(topic.rawValue)")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Text("\(matchingBooks.count) \(matchingBooks.count == 1 ? "Book" : "Books") strongly dominant")
                        .font(.caption2)
                        .foregroundColor(topic.accentColor)
                }
                
                Spacer()
                
                Text("\(topicPercent)%")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(topic.accentColor.opacity(0.18)))
                    .foregroundColor(topic.accentColor)
            }
            
            // Topic Summary
            Text(topic.summary)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.70))
                .lineSpacing(2)
            
            // Matching Books Thumbnails
            if !matchingBooks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Curriculum Books Dominating This Domain:")
                        .font(.caption2.bold())
                        .foregroundColor(Color.white.opacity(0.5))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(matchingBooks) { book in
                                Button(action: {
                                    selectedBookForDetail = book
                                }) {
                                    HStack(spacing: 8) {
                                        BookCoverView(book: book, width: 34, height: 48, cornerRadius: 5)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(book.title)
                                                .font(.caption.bold())
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                            
                                            Text("\(book.currentPage)/\(book.totalPages) pp.")
                                                .font(.caption2)
                                                .foregroundColor(Color.white.opacity(0.6))
                                        }
                                        .frame(maxWidth: 120, alignment: .leading)
                                    }
                                    .padding(6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(NocturneTheme.bgSurfaceElevated.opacity(0.7))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .liquidCard(cornerRadius: 18)
    }
}

// MARK: - Level Selector Sheet (All 10 Dark Psychology Levels)
public struct LevelSelectorSheet: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationStack {
            ZStack {
                NocturneTheme.bgVoid.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        Text("DARK PSYCHOLOGY 10-LEVEL MASTERY SYLLABUS")
                            .font(.caption.bold())
                            .foregroundColor(Color.white.opacity(0.5))
                            .tracking(1.2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(dataManager.curriculumLevels) { lvl in
                            Button(action: {
                                withAnimation {
                                    if !lvl.isUnlocked {
                                        dataManager.unlockLevel(lvl.number)
                                    }
                                    dataManager.selectedLevel = lvl.number
                                }
                            }) {
                                HStack(alignment: .top, spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(lvl.isUnlocked ? NocturneTheme.purplePrimary.opacity(0.25) : Color.white.opacity(0.06))
                                        .frame(width: 44, height: 44)
                                    
                                    if lvl.isUnlocked {
                                        Text("\(lvl.number)")
                                            .font(.headline.bold())
                                            .foregroundColor(NocturneTheme.purpleBright)
                                    } else {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color.white.opacity(0.35))
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Level \(lvl.number) — \(lvl.title)")
                                            .font(.headline)
                                            .foregroundColor(lvl.isUnlocked ? .white : Color.white.opacity(0.6))
                                        
                                        Spacer()
                                        
                                        if lvl.isUnlocked {
                                            Text("ACTIVE")
                                                .font(.caption2.bold())
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Capsule().fill(Color.green.opacity(0.2)))
                                                .foregroundColor(.green)
                                        }
                                    }
                                    
                                    Text(lvl.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(Color.white.opacity(0.5))
                                    
                                    Text(lvl.dominantTheme)
                                        .font(.caption2.weight(.medium))
                                        .foregroundColor(NocturneTheme.purpleBright.opacity(0.8))
                                        .padding(.top, 2)
                                }
                            }
                            .padding(16)
                            .liquidCard(cornerRadius: 16)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Curriculum Levels")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                            Text("Done")
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
        }
    }
}
