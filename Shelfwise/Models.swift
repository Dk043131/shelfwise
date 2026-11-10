import SwiftUI

// MARK: - Dark Psychology Curriculum Topics (Level 1 Focus)
public enum PsychologyTopic: String, CaseIterable, Identifiable, Codable {
    case cognitivePsychology = "Cognitive Psychology"
    case cognitiveBiases = "Cognitive Biases"
    case mentalModels = "Mental Models"
    case humanBehaviour = "Human Behaviour"
    case behaviouralPsychology = "Behavioural Psychology"
    case decisionMaking = "Decision-Making Psychology"
    case emotionalPsychology = "Emotional Psychology"
    case subconsciousProcesses = "Subconscious Processes"
    case motivationAndNeeds = "Motivation and Human Needs"
    case conditioningAndHabits = "Conditioning and Habit Formation"
    
    public var id: String { rawValue }
    
    public var shortName: String {
        switch self {
        case .cognitivePsychology: return "Cognitive"
        case .cognitiveBiases: return "Biases"
        case .mentalModels: return "Mental Models"
        case .humanBehaviour: return "Behaviour"
        case .behaviouralPsychology: return "Behavioural"
        case .decisionMaking: return "Decision"
        case .emotionalPsychology: return "Emotional"
        case .subconsciousProcesses: return "Subconscious"
        case .motivationAndNeeds: return "Motivation"
        case .conditioningAndHabits: return "Habits"
        }
    }
    
    public var topicNumber: Int {
        switch self {
        case .cognitivePsychology: return 1
        case .cognitiveBiases: return 2
        case .mentalModels: return 3
        case .humanBehaviour: return 4
        case .behaviouralPsychology: return 5
        case .decisionMaking: return 6
        case .emotionalPsychology: return 7
        case .subconsciousProcesses: return 8
        case .motivationAndNeeds: return 9
        case .conditioningAndHabits: return 10
        }
    }
    
    public var accentColor: Color {
        switch self {
        case .cognitivePsychology: return Color(red: 0.22, green: 0.74, blue: 0.97) // Sky blue
        case .cognitiveBiases: return Color(red: 0.98, green: 0.62, blue: 0.08) // Amber
        case .mentalModels: return Color(red: 0.08, green: 0.76, blue: 0.65) // Cyan
        case .humanBehaviour: return Color(red: 0.16, green: 0.78, blue: 0.52) // Emerald
        case .behaviouralPsychology: return Color(red: 0.39, green: 0.40, blue: 0.95) // Indigo
        case .decisionMaking: return Color(red: 0.55, green: 0.36, blue: 0.97) // Violet
        case .emotionalPsychology: return Color(red: 0.96, green: 0.25, blue: 0.37) // Rose
        case .subconsciousProcesses: return Color(red: 0.85, green: 0.27, blue: 0.94) // Fuchsia
        case .motivationAndNeeds: return Color(red: 0.98, green: 0.45, blue: 0.15) // Orange
        case .conditioningAndHabits: return Color(red: 0.52, green: 0.80, blue: 0.09) // Lime
        }
    }
    
    public var systemIcon: String {
        switch self {
        case .cognitivePsychology: return "brain.head.profile"
        case .cognitiveBiases: return "eye.trianglebadge.exclamationmark"
        case .mentalModels: return "square.stack.3d.up"
        case .humanBehaviour: return "person.3.sequence"
        case .behaviouralPsychology: return "figure.walk.motion"
        case .decisionMaking: return "point.topleft.down.curvedto.point.filled.bottomright.up"
        case .emotionalPsychology: return "heart.text.square"
        case .subconsciousProcesses: return "moon.stars"
        case .motivationAndNeeds: return "flame"
        case .conditioningAndHabits: return "arrow.triangle.2.circlepath"
        }
    }
    
    public var summary: String {
        switch self {
        case .cognitivePsychology: return "Mental structures, memory encoding, attention limits, and perception."
        case .cognitiveBiases: return "Systematic errors in thinking, heuristics, and irrational judgment patterns."
        case .mentalModels: return "Frameworks for comprehending reality, systems, and second-order effects."
        case .humanBehaviour: return "Situational forces, group conformity, and interpersonal dynamics."
        case .behaviouralPsychology: return "Observable actions, stimuli response, operant conditioning, and incentives."
        case .decisionMaking: return "Prospect theory, risk evaluation, and choices under cognitive pressure."
        case .emotionalPsychology: return "Affective regulation, empathy, somatic markers, and emotional triggers."
        case .subconsciousProcesses: return "Implicit association, subliminal cues, and automatic System 1 reflexes."
        case .motivationAndNeeds: return "Intrinsic vs extrinsic drives, status games, autonomy, and need hierarchies."
        case .conditioningAndHabits: return "Cue-routine-reward loops, neuroplastic reinforcement, and habit hacking."
        }
    }
}

// MARK: - Reading Status
public enum ReadingStatus: String, CaseIterable, Identifiable, Codable {
    case reading = "Reading"
    case wantToRead = "Want to Read"
    case completed = "Completed"
    case all = "All"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .all: return "books.vertical.fill"
        case .reading: return "book.fill"
        case .completed: return "checkmark.seal.fill"
        case .wantToRead: return "bookmark.fill"
        }
    }
    
    public var badgeColor: Color {
        switch self {
        case .all: return .secondary
        case .reading: return Color(red: 0.39, green: 0.40, blue: 0.95)
        case .completed: return Color(red: 0.16, green: 0.78, blue: 0.52)
        case .wantToRead: return Color(red: 0.98, green: 0.62, blue: 0.08)
        }
    }
}

// MARK: - Book Model
public struct Book: Identifiable, Codable, Equatable {
    public let id: UUID
    public var title: String
    public var author: String
    public var levelNumber: Int
    public var dominantTopics: [PsychologyTopic]
    public var customTopics: [String]
    public var isCurriculumBook: Bool
    public var totalPages: Int
    public var currentPage: Int
    public var status: ReadingStatus
    public var keyInsight: String
    public var gradientHexes: [String]
    public var assetCoverName: String?
    public var customCoverFileName: String?
    public var lastReadDate: Date?
    public var notesCount: Int
    
    public var displayTopics: [String] {
        if !customTopics.isEmpty {
            return customTopics
        }
        return dominantTopics.map { $0.shortName }
    }
    
    public var progressFraction: Double {
        guard totalPages > 0 else { return 0 }
        return min(max(Double(currentPage) / Double(totalPages), 0.0), 1.0)
    }
    
    public var progressPercentage: Int {
        Int(progressFraction * 100)
    }
    
    public var isCompleted: Bool {
        status == .completed || currentPage >= totalPages
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        author: String,
        levelNumber: Int = 1,
        dominantTopics: [PsychologyTopic] = [],
        customTopics: [String] = [],
        isCurriculumBook: Bool = true,
        totalPages: Int,
        currentPage: Int = 0,
        status: ReadingStatus = .wantToRead,
        keyInsight: String = "",
        gradientHexes: [String] = ["#1E1B4B", "#4338CA"],
        assetCoverName: String? = nil,
        customCoverFileName: String? = nil,
        lastReadDate: Date? = nil,
        notesCount: Int = 0
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.levelNumber = levelNumber
        self.dominantTopics = dominantTopics
        self.customTopics = customTopics
        self.isCurriculumBook = isCurriculumBook
        self.totalPages = totalPages
        self.currentPage = currentPage
        self.status = status
        self.keyInsight = keyInsight
        self.gradientHexes = gradientHexes
        self.assetCoverName = assetCoverName
        self.customCoverFileName = customCoverFileName
        self.lastReadDate = lastReadDate
        self.notesCount = notesCount
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, author, levelNumber, dominantTopics, customTopics, isCurriculumBook
        case totalPages, currentPage, status, keyInsight, gradientHexes
        case assetCoverName, customCoverFileName, lastReadDate, notesCount
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.author = try container.decode(String.self, forKey: .author)
        self.levelNumber = try container.decodeIfPresent(Int.self, forKey: .levelNumber) ?? 1
        self.dominantTopics = try container.decodeIfPresent([PsychologyTopic].self, forKey: .dominantTopics) ?? []
        self.customTopics = try container.decodeIfPresent([String].self, forKey: .customTopics) ?? []
        self.isCurriculumBook = try container.decodeIfPresent(Bool.self, forKey: .isCurriculumBook) ?? true
        self.totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages) ?? 0
        self.currentPage = try container.decodeIfPresent(Int.self, forKey: .currentPage) ?? 0
        self.status = try container.decodeIfPresent(ReadingStatus.self, forKey: .status) ?? .wantToRead
        self.keyInsight = try container.decodeIfPresent(String.self, forKey: .keyInsight) ?? ""
        self.gradientHexes = try container.decodeIfPresent([String].self, forKey: .gradientHexes) ?? ["#1E1B4B", "#4338CA"]
        self.assetCoverName = try container.decodeIfPresent(String.self, forKey: .assetCoverName)
        self.customCoverFileName = try container.decodeIfPresent(String.self, forKey: .customCoverFileName)
        self.lastReadDate = try container.decodeIfPresent(Date.self, forKey: .lastReadDate)
        self.notesCount = try container.decodeIfPresent(Int.self, forKey: .notesCount) ?? 0
    }
}

// MARK: - Daily Photo Note (Apple Notes-Style with Multiple Images & Page Range)
public struct DailyPhotoNote: Identifiable, Codable, Equatable {
    public let id: UUID
    public var bookId: UUID
    public var bookTitle: String
    public var timestamp: Date
    public var imageFileName: String
    public var imageFileNames: [String]
    public var pageNumber: Int?
    public var fromPage: Int?
    public var toPage: Int?
    public var summaryText: String?
    public var isCloudSynced: Bool
    public var dominantTopic: PsychologyTopic?
    public var cloudId: String
    
    public var allImages: [String] {
        if !imageFileNames.isEmpty {
            return imageFileNames
        }
        return [imageFileName].filter { !$0.isEmpty }
    }
    
    public var pageRangeDescription: String? {
        if let from = fromPage, let to = toPage {
            if from == to {
                return "Page \(from)"
            } else {
                return "Pages \(from)–\(to)"
            }
        } else if let page = pageNumber {
            return "Page \(page)"
        } else if let from = fromPage {
            return "Page \(from)"
        } else if let to = toPage {
            return "Page \(to)"
        }
        return nil
    }
    
    public init(
        id: UUID = UUID(),
        bookId: UUID,
        bookTitle: String,
        timestamp: Date = Date(),
        imageFileName: String,
        imageFileNames: [String] = [],
        pageNumber: Int? = nil,
        fromPage: Int? = nil,
        toPage: Int? = nil,
        summaryText: String? = nil,
        isCloudSynced: Bool = true,
        dominantTopic: PsychologyTopic? = nil,
        cloudId: String = UUID().uuidString
    ) {
        self.id = id
        self.bookId = bookId
        self.bookTitle = bookTitle
        self.timestamp = timestamp
        self.imageFileName = imageFileName
        self.imageFileNames = imageFileNames.isEmpty ? [imageFileName] : imageFileNames
        self.pageNumber = pageNumber ?? fromPage
        self.fromPage = fromPage ?? pageNumber
        self.toPage = toPage ?? fromPage ?? pageNumber
        self.summaryText = summaryText
        self.isCloudSynced = isCloudSynced
        self.dominantTopic = dominantTopic
        self.cloudId = cloudId
    }
}

// MARK: - Reading Log Entry
public struct ReadingLogEntry: Identifiable, Codable {
    public let id: UUID
    public var bookId: UUID
    public var date: Date
    public var pagesLogged: Int
    public var endPage: Int
    
    public init(
        id: UUID = UUID(),
        bookId: UUID,
        date: Date = Date(),
        pagesLogged: Int,
        endPage: Int
    ) {
        self.id = id
        self.bookId = bookId
        self.date = date
        self.pagesLogged = pagesLogged
        self.endPage = endPage
    }
}

// MARK: - Curriculum Level Model
public struct CurriculumLevel: Identifiable, Codable {
    public let number: Int
    public let title: String
    public let subtitle: String
    public var isUnlocked: Bool
    public var bookCount: Int
    public var dominantTheme: String
    
    public var id: Int { number }
}
