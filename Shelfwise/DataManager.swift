import SwiftUI
import Combine

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

@MainActor
public final class DataManager: ObservableObject {
    public static let shared = DataManager()
    
    // MARK: - Published State
    @Published public var books: [Book] = []
    @Published public var photoNotes: [DailyPhotoNote] = []
    @Published public var readingLogs: [ReadingLogEntry] = []
    @Published public var selectedLevel: Int = 1
    @Published public var currentStreakDays: Int = 0
    @Published public var weeklyPageGoal: Int = 200
    @Published public var isCloudSyncing: Bool = false
    @Published public var lastCloudSyncDate: Date = Date()
    
    // Cache for loaded images from disk
    private var imageMemoryCache: [String: PlatformImage] = [:]
    
    private let booksStorageKey = "shelfwise_curriculum_books_v2"
    private let notesStorageKey = "shelfwise_photo_notes_v2"
    private let logsStorageKey = "shelfwise_reading_logs_v2"
    private let streakStorageKey = "shelfwise_streak_days_v2"
    private let unlockedLevelKey = "shelfwise_unlocked_level_v2"
    
    @Published public var highestUnlockedLevel: Int = 1
    
    // MARK: - Curriculum Levels List
    public var curriculumLevels: [CurriculumLevel] {
        [
            CurriculumLevel(
                number: 1,
                title: "Understanding the human mind",
                subtitle: "The foundation of everything.",
                isUnlocked: true,
                bookCount: 13,
                dominantTheme: "Cognitive, Behavioural & Habit Architectures"
            ),
            CurriculumLevel(
                number: 2,
                title: "Social Dynamics & Perception",
                subtitle: "The hidden architecture of groups.",
                isUnlocked: highestUnlockedLevel >= 2,
                bookCount: 10,
                dominantTheme: "Conformity, Status Hierarchies & Tribalism"
            ),
            CurriculumLevel(
                number: 3,
                title: "Persuasion, Framing & Influence",
                subtitle: "Weaponized rhetoric and linguistic framing.",
                isUnlocked: highestUnlockedLevel >= 3,
                bookCount: 12,
                dominantTheme: "Compliance, Reciprocity & Anchoring"
            ),
            CurriculumLevel(
                number: 4,
                title: "Micro-Expressions & Non-Verbal Signals",
                subtitle: "The somatic leaks of suppressed intent.",
                isUnlocked: highestUnlockedLevel >= 4,
                bookCount: 8,
                dominantTheme: "Kinesics, Baselines & Deception Leakage"
            ),
            CurriculumLevel(
                number: 5,
                title: "Deception & Psychological Countermeasures",
                subtitle: "Dissecting falsehoods and gaslighting.",
                isUnlocked: highestUnlockedLevel >= 5,
                bookCount: 9,
                dominantTheme: "Cognitive Load in Lies & Micro-Truths"
            ),
            CurriculumLevel(
                number: 6,
                title: "Dark Triad & Machiavellian Strategy",
                subtitle: "Narcissism, Machiavellianism & Psychopathy.",
                isUnlocked: highestUnlockedLevel >= 6,
                bookCount: 11,
                dominantTheme: "Calculated Empathy & Zero-Sum Games"
            ),
            CurriculumLevel(
                number: 7,
                title: "Ego Depletion & Emotional Exploitation",
                subtitle: "Navigating targeted vulnerability windows.",
                isUnlocked: highestUnlockedLevel >= 7,
                bookCount: 7,
                dominantTheme: "Somatic Fatigue & Emotional Anchors"
            ),
            CurriculumLevel(
                number: 8,
                title: "Subliminal Conditioning & Cult Dynamics",
                subtitle: "How belief systems are indoctrinated.",
                isUnlocked: highestUnlockedLevel >= 8,
                bookCount: 9,
                dominantTheme: "Love Bombing, Isolation & Identity Eradication"
            ),
            CurriculumLevel(
                number: 9,
                title: "Strategic Negotiation & Game Theory",
                subtitle: "Rational choices in adversarial environments.",
                isUnlocked: highestUnlockedLevel >= 9,
                bookCount: 8,
                dominantTheme: "Nash Equilibrium, Ultimatums & Leverage"
            ),
            CurriculumLevel(
                number: 10,
                title: "The Master Synthesizer",
                subtitle: "Total psychological sovereignty.",
                isUnlocked: highestUnlockedLevel >= 10,
                bookCount: 10,
                dominantTheme: "Integrated Psychological Defense & Analysis"
            )
        ]
    }
    
    // MARK: - Initializer
    private init() {
        // Clear previous dummy data completely if needed
        UserDefaults.standard.removeObject(forKey: "nocturne_curriculum_books_v1")
        UserDefaults.standard.removeObject(forKey: "nocturne_photo_notes_v1")
        UserDefaults.standard.removeObject(forKey: "nocturne_reading_logs_v1")
        
        loadData()
        if books.isEmpty {
            resetToFreshCurriculum()
        }
    }
    
    // MARK: - Reset All Data to Clean 0% Progress with Real Book Thumbnails
    public func resetToFreshCurriculum() {
        self.books = [
            Book(
                title: "Thinking, Fast and Slow",
                author: "Daniel Kahneman",
                levelNumber: 1,
                dominantTopics: [.cognitiveBiases, .decisionMaking],
                totalPages: 512,
                currentPage: 0,
                status: .wantToRead,
                keyInsight: "System 1 operates automatically and quickly, with little effort, while System 2 allocates attention to effortful mental operations.",
                gradientHexes: ["#1E1B4B", "#4338CA", "#6366F1"],
                assetCoverName: "thinking_fast_and_slow",
                notesCount: 0
            ),
            Book(
                title: "Predictably Irrational",
                author: "Dan Ariely",
                levelNumber: 1,
                dominantTopics: [.behaviouralPsychology, .cognitiveBiases],
                totalPages: 384,
                currentPage: 0,
                status: .wantToRead,
                keyInsight: "Humans are not only irrational, but predictably so—our irrationality occurs repeatedly and systematically.",
                gradientHexes: ["#0F172A", "#0369A1", "#0284C7"],
                assetCoverName: "predictably_irrational",
                notesCount: 0
            ),
            Book(
                title: "The Art of Thinking Clearly",
                author: "Rolf Dobelli",
                levelNumber: 1,
                dominantTopics: [.cognitiveBiases, .mentalModels],
                totalPages: 384,
                currentPage: 0,
                status: .wantToRead,
                keyInsight: "A compendium of 99 cognitive traps: confirmation bias, swimmer's body illusion, and survivorship fallacy.",
                gradientHexes: ["#14251B", "#065F46", "#10B981"],
                assetCoverName: "art_of_thinking_clearly",
                notesCount: 0
            ),
            Book(
                title: "The Invisible Gorilla",
                author: "Christopher Chabris & Daniel Simons",
                levelNumber: 1,
                dominantTopics: [.subconsciousProcesses, .cognitivePsychology],
                totalPages: 336,
                currentPage: 0,
                status: .wantToRead,
                keyInsight: "Our minds don't simply record the world; they construct an illusion of seeing everything when we miss the obvious.",
                gradientHexes: ["#31102B", "#701A75", "#C026D3"],
                assetCoverName: "invisible_gorilla",
                notesCount: 0
            ),
            Book(
                title: "Mistakes Were Made (But Not by Me)",
                author: "Carol Tavris & Elliot Aronson",
                levelNumber: 1,
                dominantTopics: [.humanBehaviour, .cognitiveBiases],
                totalPages: 368,
                currentPage: 0,
                status: .wantToRead,
                keyInsight: "Why we justify foolish beliefs, bad decisions, and hurtful acts through cognitive dissonance reduction.",
                gradientHexes: ["#291811", "#9A3412", "#EA580C"],
                assetCoverName: "mistakes_were_made",
                notesCount: 0
            ),
            Book(
                title: "Noise: A Flaw in Human Judgment",
                author: "Daniel Kahneman, Olivier Sibony & Cass Sunstein",
                levelNumber: 1,
                dominantTopics: [.decisionMaking, .cognitivePsychology],
                totalPages: 464,
                currentPage: 0,
                status: .wantToRead,
                keyInsight: "Wherever there is judgment, there is noise—unwanted variability in evaluations that should be identical.",
                gradientHexes: ["#18181B", "#27272A", "#71717A"],
                assetCoverName: "noise_kahneman",
                notesCount: 0
            ),
            Book(
                title: "Nudge",
                author: "Richard Thaler & Cass Sunstein",
                levelNumber: 1,
                dominantTopics: [.behaviouralPsychology, .decisionMaking],
                totalPages: 320,
                currentPage: 0,
                status: .wantToRead,
                keyInsight: "Choice architecture and libertarian paternalism: guiding choices without forbidding any options.",
                gradientHexes: ["#1E1B4B", "#3B82F6", "#60A5FA"],
                assetCoverName: "nudge_thaler",
                notesCount: 0
            ),
            Book(
                title: "The Person and the Situation",
                author: "Lee Ross & Richard Nisbett",
                levelNumber: 1,
                dominantTopics: [.humanBehaviour, .behaviouralPsychology],
                totalPages: 320,
                currentPage: 0,
                status: .wantToRead,
                keyInsight: "The fundamental attribution error: overemphasizing internal personality traits and underestimating situational contexts.",
                gradientHexes: ["#1E293B", "#334155", "#64748B"],
                assetCoverName: "person_and_situation",
                notesCount: 0
            ),
            Book(
                title: "Emotional Intelligence",
                author: "Daniel Goleman",
                levelNumber: 1,
                dominantTopics: [.emotionalPsychology],
                totalPages: 384,
                currentPage: 0,
                status: .wantToRead,
                keyInsight: "The amygdala hijack and self-regulation: why emotional competency predicts outcomes better than raw IQ.",
                gradientHexes: ["#3F121E", "#881337", "#E11D48"],
                assetCoverName: "emotional_intelligence",
                notesCount: 0
            ),
            Book(
                title: "Drive: The Surprising Truth About What Motivates Us",
                author: "Daniel H. Pink",
                levelNumber: 1,
                dominantTopics: [.motivationAndNeeds],
                totalPages: 288,
                currentPage: 0,
                status: .wantToRead,
                keyInsight: "Carrot-and-stick incentives backfire for complex tasks; motivation 3.0 requires autonomy, mastery, and purpose.",
                gradientHexes: ["#3A1A05", "#9A3412", "#FB923C"],
                assetCoverName: "drive_pink",
                notesCount: 0
            ),
            Book(
                title: "The Power of Habit",
                author: "Charles Duhigg",
                levelNumber: 1,
                dominantTopics: [.conditioningAndHabits],
                totalPages: 416,
                currentPage: 0,
                status: .wantToRead,
                keyInsight: "The habit loop (cue, routine, reward) stored in the basal ganglia. Habits cannot be eradicated, only substituted.",
                gradientHexes: ["#162816", "#15803D", "#4ADE80"],
                assetCoverName: "power_of_habit",
                notesCount: 0
            ),
            Book(
                title: "Thinking and Deciding",
                author: "Jonathan Baron",
                levelNumber: 1,
                dominantTopics: [.decisionMaking, .mentalModels],
                totalPages: 600,
                currentPage: 0,
                status: .wantToRead,
                keyInsight: "Normative, descriptive, and prescriptive models of rational decision theory and Bayesian inference.",
                gradientHexes: ["#241539", "#581C87", "#A855F7"],
                assetCoverName: "thinking_and_deciding",
                notesCount: 0
            ),
            Book(
                title: "Social Psychology",
                author: "David Myers & Elliot Aronson",
                levelNumber: 1,
                dominantTopics: [.humanBehaviour, .cognitivePsychology],
                totalPages: 544,
                currentPage: 0,
                status: .wantToRead,
                keyInsight: "Social thinking, persuasion dynamics, group polarization, and the social construction of reality.",
                gradientHexes: ["#0C2534", "#0369A1", "#38BDF8"],
                assetCoverName: "social_psychology",
                notesCount: 0
            )
        ]
        
        self.photoNotes = []
        self.readingLogs = []
        self.currentStreakDays = 0
        
        saveBooks()
        saveNotes()
        saveLogs()
        UserDefaults.standard.set(0, forKey: streakStorageKey)
    }
    
    // MARK: - Daily Single Log Enforcement
    public func hasLoggedToday(for bookId: UUID) -> Bool {
        let calendar = Calendar.current
        return readingLogs.contains { entry in
            entry.bookId == bookId && calendar.isDateInToday(entry.date)
        }
    }
    
    // MARK: - Progress Updates (Enforces 1 Log per Day per Book)
    @discardableResult
    public func logReadingSession(bookId: UUID, pagesRead: Int, notesSummary: String? = nil) -> Bool {
        if hasLoggedToday(for: bookId) {
            return false
        }
        
        guard let index = books.firstIndex(where: { $0.id == bookId }) else { return false }
        
        let newPage = min(books[index].totalPages, books[index].currentPage + pagesRead)
        books[index].currentPage = newPage
        books[index].lastReadDate = Date()
        
        if books[index].currentPage >= books[index].totalPages {
            books[index].status = .completed
        } else if books[index].status == .wantToRead {
            books[index].status = .reading
        }
        
        let log = ReadingLogEntry(
            bookId: bookId,
            date: Date(),
            pagesLogged: pagesRead,
            endPage: newPage
        )
        readingLogs.insert(log, at: 0)
        recalculateStreak()
        
        saveBooks()
        saveLogs()
        checkAndPromoteLevelCompletion()
        return true
    }
    
    public func updateBookProgress(bookId: UUID, newPage: Int) {
        if hasLoggedToday(for: bookId) {
            return
        }
        guard let index = books.firstIndex(where: { $0.id == bookId }) else { return }
        let clampedPage = min(max(0, newPage), books[index].totalPages)
        let delta = clampedPage - books[index].currentPage
        
        books[index].currentPage = clampedPage
        books[index].lastReadDate = Date()
        
        if clampedPage >= books[index].totalPages {
            books[index].status = .completed
        } else if books[index].status == .wantToRead && clampedPage > 0 {
            books[index].status = .reading
        }
        
        if delta > 0 {
            let log = ReadingLogEntry(
                bookId: bookId,
                date: Date(),
                pagesLogged: delta,
                endPage: clampedPage
            )
            readingLogs.insert(log, at: 0)
            recalculateStreak()
            saveLogs()
        }
        
        saveBooks()
    }
    
    public func updateBookStatus(bookId: UUID, newStatus: ReadingStatus) {
        guard let index = books.firstIndex(where: { $0.id == bookId }) else { return }
        books[index].status = newStatus
        if newStatus == .completed {
            books[index].currentPage = books[index].totalPages
        }
        saveBooks()
    }
    
    // MARK: - Photo Note Creation (With Multiple Images & From/To Page Range)
    public func addPhotoNotes(
        images: [PlatformImage],
        book: Book,
        fromPage: Int?,
        toPage: Int?,
        summaryText: String? = nil
    ) {
        guard !images.isEmpty else { return }
        
        var fileNames: [String] = []
        for img in images {
            let fn = "note_\(UUID().uuidString).jpg"
            saveImageToDisk(image: img, fileName: fn)
            fileNames.append(fn)
        }
        
        let primaryFileName = fileNames.first ?? ""
        let calculatedPage = fromPage ?? toPage
        
        let newNote = DailyPhotoNote(
            bookId: book.id,
            bookTitle: book.title,
            timestamp: Date(),
            imageFileName: primaryFileName,
            imageFileNames: fileNames,
            pageNumber: calculatedPage,
            fromPage: fromPage,
            toPage: toPage,
            summaryText: summaryText,
            isCloudSynced: false,
            dominantTopic: book.dominantTopics.first
        )
        
        photoNotes.insert(newNote, at: 0)
        
        if let bookIdx = books.firstIndex(where: { $0.id == book.id }) {
            books[bookIdx].notesCount += 1
            if let to = toPage, to > books[bookIdx].currentPage {
                books[bookIdx].currentPage = min(books[bookIdx].totalPages, to)
                if books[bookIdx].currentPage >= books[bookIdx].totalPages {
                    books[bookIdx].status = .completed
                } else if books[bookIdx].status == .wantToRead {
                    books[bookIdx].status = .reading
                }
            }
            saveBooks()
        }
        
        saveNotes()
        triggerCloudSync(for: newNote.id)
    }
    
    public func addPhotoNote(image: PlatformImage, book: Book, pageNumber: Int?, summaryText: String? = nil) {
        addPhotoNotes(
            images: [image],
            book: book,
            fromPage: pageNumber,
            toPage: pageNumber,
            summaryText: summaryText
        )
    }
    
    public func deletePhotoNote(_ note: DailyPhotoNote) {
        for fn in note.allImages {
            deleteImageFromDisk(fileName: fn)
        }
        photoNotes.removeAll(where: { $0.id == note.id })
        if let bookIdx = books.firstIndex(where: { $0.id == note.bookId }) {
            books[bookIdx].notesCount = max(0, books[bookIdx].notesCount - 1)
            saveBooks()
        }
        saveNotes()
    }
    
    public func triggerCloudSync(for noteId: UUID) {
        self.isCloudSyncing = true
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            await MainActor.run {
                if let idx = self.photoNotes.firstIndex(where: { $0.id == noteId }) {
                    self.photoNotes[idx].isCloudSynced = true
                    self.saveNotes()
                }
                self.isCloudSyncing = false
                self.lastCloudSyncDate = Date()
            }
        }
    }
    
    public func syncAllNotesToCloud() {
        self.isCloudSyncing = true
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            await MainActor.run {
                for i in 0..<self.photoNotes.count {
                    self.photoNotes[i].isCloudSynced = true
                }
                self.isCloudSyncing = false
                self.lastCloudSyncDate = Date()
                self.saveNotes()
            }
        }
    }
    
    // MARK: - Personal Books Management
    public var myPersonalBooks: [Book] {
        books.filter { !$0.isCurriculumBook }
    }
    
    public var curriculumBooks: [Book] {
        books.filter { $0.isCurriculumBook }
    }
    
    public func addPersonalBook(
        title: String,
        author: String,
        totalPages: Int,
        currentPage: Int = 0,
        status: ReadingStatus = .wantToRead,
        keyInsight: String,
        customTopics: [String],
        coverData: Data? = nil
    ) -> Book {
        var customCoverFileName: String? = nil
        if let data = coverData, let img = PlatformImage(data: data) {
            let fn = "cover_\(UUID().uuidString).jpg"
            saveImageToDisk(image: img, fileName: fn)
            customCoverFileName = fn
        }
        
        let newBook = Book(
            title: title,
            author: author,
            levelNumber: 0,
            dominantTopics: [],
            customTopics: customTopics,
            isCurriculumBook: false,
            totalPages: max(1, totalPages),
            currentPage: currentPage,
            status: status,
            keyInsight: keyInsight,
            gradientHexes: ["#1e293b", "#334155"],
            assetCoverName: nil,
            customCoverFileName: customCoverFileName,
            notesCount: 0
        )
        
        books.append(newBook)
        saveBooks()
        // If this book belongs to a currently unlocked level, immediately absorb it into curriculum
        absorbExtraBooksForUnlockedLevels()
        return newBook
    }
    

    // MARK: - Level Unlocking & Extra Books Absorption
    public func unlockLevel(_ levelNumber: Int) {
        guard levelNumber > highestUnlockedLevel && levelNumber <= 10 else { return }
        highestUnlockedLevel = levelNumber
        UserDefaults.standard.set(highestUnlockedLevel, forKey: unlockedLevelKey)
        absorbExtraBooksForUnlockedLevels()
    }
    
    public func checkAndPromoteLevelCompletion() {
        // If all curriculum books in the current highest unlocked level are completed, unlock next level
        let currentLevelBooks = books.filter { $0.isCurriculumBook && $0.levelNumber == highestUnlockedLevel }
        if !currentLevelBooks.isEmpty && currentLevelBooks.allSatisfy({ $0.isCompleted }) {
            if highestUnlockedLevel < 10 {
                unlockLevel(highestUnlockedLevel + 1)
            }
        }
    }
    
    /// Checks all extra books; if an extra book matches any book in unlocked curriculum levels,
    /// it transfers its reading progress, notes, and status to curriculum and removes it from extra books.
    public func absorbExtraBooksForUnlockedLevels() {
        var didModify = false
        
        // 1. First, check master catalog for any master books that belong to newly unlocked levels
        // and populate them into curriculum if they are not already in curriculum
        for masterBook in CurriculumCatalog.allMasterBooks {
            if masterBook.levelNumber <= highestUnlockedLevel {
                let alreadyInCurriculum = books.contains { $0.isCurriculumBook && CurriculumCatalog.doesMatch(titleA: $0.title, titleB: masterBook.title) }
                if !alreadyInCurriculum {
                    // Check if user already read or has this in extra books
                    if let extraIdx = books.firstIndex(where: { !$0.isCurriculumBook && CurriculumCatalog.doesMatch(titleA: $0.title, titleB: masterBook.title) }) {
                        var extraBook = books[extraIdx]
                        // Absorb extra book into curriculum!
                        extraBook.isCurriculumBook = true
                        extraBook.levelNumber = masterBook.levelNumber
                        if extraBook.dominantTopics.isEmpty {
                            extraBook.dominantTopics = masterBook.dominantTopics
                        }
                        if extraBook.totalPages <= 0 {
                            extraBook.totalPages = masterBook.totalPages
                        }
                        if extraBook.keyInsight.isEmpty {
                            extraBook.keyInsight = masterBook.keyInsight
                        }
                        // Update in place
                        books[extraIdx] = extraBook
                        didModify = true
                    } else {
                        // Add fresh curriculum book for unlocked level
                        let newCurriculumBook = Book(
                            title: masterBook.title,
                            author: masterBook.author,
                            levelNumber: masterBook.levelNumber,
                            dominantTopics: masterBook.dominantTopics,
                            customTopics: masterBook.customTopics,
                            isCurriculumBook: true,
                            totalPages: masterBook.totalPages,
                            currentPage: 0,
                            status: .wantToRead,
                            keyInsight: masterBook.keyInsight,
                            gradientHexes: masterBook.gradientHexes,
                            assetCoverName: masterBook.assetCoverName,
                            notesCount: 0
                        )
                        books.append(newCurriculumBook)
                        didModify = true
                    }
                }
            }
        }
        
        // 2. Also check if any existing extra book was manually titled to match any existing curriculum book
        for curriculumBook in books.filter({ $0.isCurriculumBook }) {
            let matchingExtraBooks = books.filter { !$0.isCurriculumBook && CurriculumCatalog.doesMatch(titleA: $0.title, titleB: curriculumBook.title) }
            for extraBook in matchingExtraBooks {
                // Transfer progress if extra book has higher progress
                if let currIdx = books.firstIndex(where: { $0.id == curriculumBook.id }) {
                    if extraBook.currentPage > books[currIdx].currentPage {
                        books[currIdx].currentPage = extraBook.currentPage
                    }
                    if extraBook.isCompleted {
                        books[currIdx].status = .completed
                    } else if extraBook.currentPage > 0 {
                        books[currIdx].status = .reading
                    }
                    // Transfer any photo notes tied to extraBook.id to curriculumBook.id
                    for nIdx in photoNotes.indices {
                        if photoNotes[nIdx].bookId == extraBook.id {
                            photoNotes[nIdx].bookId = curriculumBook.id
                            photoNotes[nIdx].bookTitle = curriculumBook.title
                        }
                    }
                    // Transfer reading logs
                    for lIdx in readingLogs.indices {
                        if readingLogs[lIdx].bookId == extraBook.id {
                            readingLogs[lIdx].bookId = curriculumBook.id
                        }
                    }
                }
                // Remove the extra book duplicate
                books.removeAll(where: { $0.id == extraBook.id })
                didModify = true
            }
        }
        
        if didModify {
            saveBooks()
            saveNotes()
            saveLogs()
        }
    }

    public func deletePersonalBook(_ book: Book) {
        if let fn = book.customCoverFileName {
            deleteImageFromDisk(fileName: fn)
        }
        books.removeAll(where: { $0.id == book.id })
        saveBooks()
    }

    // MARK: - Calculations & Stats (Curriculum Books Only)
    public var totalPagesRead: Int {
        curriculumBooks.reduce(0) { $0 + $1.currentPage }
    }
    
    public var readingBooksCount: Int {
        curriculumBooks.filter { $0.status == .reading }.count
    }
    
    public var completedLevel1Pages: Int {
        totalPagesRead
    }
    
    public var totalLevel1Pages: Int {
        curriculumBooks.reduce(0) { $0 + $1.totalPages }
    }
    
    public func pagesReadInCurrentWeek() -> Int {
        weeklyPagesReadTotal
    }
    
    public struct DayPageStat: Identifiable {
        public var id: String { dayName }
        public let dayName: String
        public let pages: Int
        public let isToday: Bool
    }
    
    public func dailyPagesForPast7Days() -> [DayPageStat] {
        let calendar = Calendar.current
        let today = Date()
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        
        var stats: [DayPageStat] = []
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let curriculumIds = Set(books.filter { $0.isCurriculumBook }.map { $0.id })
            let pages = readingLogs.filter { calendar.isDate($0.date, inSameDayAs: date) && curriculumIds.contains($0.bookId) }.reduce(0) { $0 + $1.pagesLogged }
            let name = calendar.isDateInToday(date) ? "Today" : dayFormatter.string(from: date)
            stats.append(DayPageStat(dayName: name, pages: pages, isToday: calendar.isDateInToday(date)))
        }
        return stats
    }
    
    public var completedBooksCount: Int {
        curriculumBooks.filter { $0.isCompleted }.count
    }
    
    public var overallLevel1ProgressPercent: Int {
        let totalPages = curriculumBooks.reduce(0) { $0 + $1.totalPages }
        guard totalPages > 0 else { return 0 }
        return Int((Double(totalPagesRead) / Double(totalPages)) * 100)
    }
    
    public func topicProgress(for topic: PsychologyTopic) -> Double {
        let matchingBooks = books.filter { $0.dominantTopics.contains(topic) }
        guard !matchingBooks.isEmpty else { return 0.0 }
        let total = matchingBooks.reduce(0) { $0 + $1.totalPages }
        let read = matchingBooks.reduce(0) { $0 + $1.currentPage }
        guard total > 0 else { return 0.0 }
        return Double(read) / Double(total)
    }
    
    public var weeklyPagesReadTotal: Int {
        let calendar = Calendar.current
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return 0 }
        // Exclude extra books: only count curriculum books towards weekly targets!
        let curriculumIds = Set(books.filter { $0.isCurriculumBook }.map { $0.id })
        return readingLogs
            .filter { $0.date >= sevenDaysAgo && curriculumIds.contains($0.bookId) }
            .reduce(0) { $0 + $1.pagesLogged }
    }
    
    private func recalculateStreak() {
        let calendar = Calendar.current
        var currentCheck = Date()
        var streak = 0
        
        while true {
            let hasReadOnDay = readingLogs.contains { entry in
                calendar.isDate(entry.date, inSameDayAs: currentCheck)
            }
            if hasReadOnDay {
                streak += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: currentCheck) else { break }
                currentCheck = prev
            } else {
                if streak == 0 {
                    if let yesterday = calendar.date(byAdding: .day, value: -1, to: currentCheck),
                       readingLogs.contains(where: { calendar.isDate($0.date, inSameDayAs: yesterday) }) {
                        currentCheck = yesterday
                        continue
                    }
                }
                break
            }
        }
        self.currentStreakDays = streak
        UserDefaults.standard.set(streak, forKey: streakStorageKey)
    }
    
    // MARK: - Persistence (UserDefaults & Documents)
    private func saveBooks() {
        if let encoded = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(encoded, forKey: booksStorageKey)
        }
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(photoNotes) {
            UserDefaults.standard.set(encoded, forKey: notesStorageKey)
        }
    }
    
    private func saveLogs() {
        if let encoded = try? JSONEncoder().encode(readingLogs) {
            UserDefaults.standard.set(encoded, forKey: logsStorageKey)
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: booksStorageKey),
           let decoded = try? JSONDecoder().decode([Book].self, from: data) {
            self.books = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: notesStorageKey),
           let decoded = try? JSONDecoder().decode([DailyPhotoNote].self, from: data) {
            self.photoNotes = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: logsStorageKey),
           let decoded = try? JSONDecoder().decode([ReadingLogEntry].self, from: data) {
            self.readingLogs = decoded
        }
        
        self.currentStreakDays = UserDefaults.standard.integer(forKey: streakStorageKey)
        let savedLevel = UserDefaults.standard.integer(forKey: unlockedLevelKey)
        self.highestUnlockedLevel = max(1, savedLevel)
    }
    
    // MARK: - Image Disk Caching
    public func loadImage(fileName: String) -> PlatformImage? {
        if let cached = imageMemoryCache[fileName] {
            return cached
        }
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        #if canImport(UIKit)
        if let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            imageMemoryCache[fileName] = image
            return image
        }
        #endif
        return nil
    }
    
    private func saveImageToDisk(image: PlatformImage, fileName: String) {
        #if canImport(UIKit)
        if let data = image.jpegData(compressionQuality: 0.8) {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            try? data.write(to: url)
            imageMemoryCache[fileName] = image
        }
        #endif
    }
    
    private func deleteImageFromDisk(fileName: String) {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
        imageMemoryCache.removeValue(forKey: fileName)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
