import Foundation
import SwiftUI

public struct CurriculumMasterEntry {
    public let title: String
    public let author: String
    public let levelNumber: Int
    public let dominantTopics: [PsychologyTopic]
    public let customTopics: [String]
    public let totalPages: Int
    public let keyInsight: String
    public let gradientHexes: [String]
    public let assetCoverName: String?
    
    public init(
        title: String,
        author: String,
        levelNumber: Int,
        dominantTopics: [PsychologyTopic] = [],
        customTopics: [String] = [],
        totalPages: Int,
        keyInsight: String,
        gradientHexes: [String] = ["#1E1B4B", "#4338CA"],
        assetCoverName: String? = nil
    ) {
        self.title = title
        self.author = author
        self.levelNumber = levelNumber
        self.dominantTopics = dominantTopics
        self.customTopics = customTopics
        self.totalPages = totalPages
        self.keyInsight = keyInsight
        self.gradientHexes = gradientHexes
        self.assetCoverName = assetCoverName
    }
}

public struct CurriculumCatalog {
    /// Normalized matching helper
    public static func normalizeTitle(_ title: String) -> String {
        let pattern = "[^a-zA-Z0-9 ]"
        let stripped = title.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        let singleSpaced = stripped.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .lowercased()
        // Strip leading "the " for resilient matching
        if singleSpaced.hasPrefix("the ") {
            return String(singleSpaced.dropFirst(4))
        }
        return singleSpaced
    }
    
    public static func doesMatch(titleA: String, titleB: String) -> Bool {
        let normA = normalizeTitle(titleA)
        let normB = normalizeTitle(titleB)
        if normA == normB { return true }
        if normA.contains(normB) || normB.contains(normA) { return true }
        return false
    }
    
    /// Finds if a book title belongs to a higher curriculum level
    public static func findMasterEntry(forTitle title: String) -> CurriculumMasterEntry? {
        allMasterBooks.first { doesMatch(titleA: $0.title, titleB: title) }
    }
    
    /// Full Dark Psychology 10-Level Catalog
    public static let allMasterBooks: [CurriculumMasterEntry] = [
        // Level 2: Social Dynamics & Perception
        CurriculumMasterEntry(
            title: "The 48 Laws of Power",
            author: "Robert Greene",
            levelNumber: 2,
            dominantTopics: [.humanBehaviour, .cognitivePsychology],
            customTopics: ["Dark Triad & Strategy", "Power Dynamics"],
            totalPages: 452,
            keyInsight: "Synthesizes three thousand years of the history of power into 48 essential, pragmatic laws.",
            gradientHexes: ["#1e1b4b", "#7c2d12"]
        ),
        CurriculumMasterEntry(
            title: "The Laws of Human Nature",
            author: "Robert Greene",
            levelNumber: 2,
            dominantTopics: [.humanBehaviour, .emotionalPsychology],
            customTopics: ["Social Perception", "Shadow Self"],
            totalPages: 624,
            keyInsight: "Decodes human drives, unconscious envy, grandiosity, and the underlying architecture of personal character.",
            gradientHexes: ["#09090b", "#431407"]
        ),
        CurriculumMasterEntry(
            title: "Influence: The Psychology of Persuasion",
            author: "Robert B. Cialdini",
            levelNumber: 2,
            dominantTopics: [.behaviouralPsychology, .decisionMaking],
            customTopics: ["Compliance Principles", "Social Proof"],
            totalPages: 336,
            keyInsight: "The 6 fundamental principles of compliance: Reciprocity, Scarcity, Authority, Consistency, Liking, and Consensus.",
            gradientHexes: ["#1e293b", "#0f766e"]
        ),
        CurriculumMasterEntry(
            title: "Games People Play",
            author: "Eric Berne",
            levelNumber: 2,
            dominantTopics: [.humanBehaviour, .subconsciousProcesses],
            customTopics: ["Transactional Analysis", "Ego States"],
            totalPages: 192,
            keyInsight: "Examines the underlying games, scripts, and transactional manoeuvres governing human relationships.",
            gradientHexes: ["#1e1b4b", "#6b21a8"]
        ),
        CurriculumMasterEntry(
            title: "The Lucifer Effect",
            author: "Philip Zimbardo",
            levelNumber: 2,
            dominantTopics: [.humanBehaviour, .behaviouralPsychology],
            customTopics: ["Conformity", "Deindividuation"],
            totalPages: 576,
            keyInsight: "How situational pressure, conformity, and systemic structures transform ordinary people into perpetrators.",
            gradientHexes: ["#18181b", "#991b1b"]
        ),
        
        // Level 3: Persuasion, Framing & Influence
        CurriculumMasterEntry(
            title: "Pre-Suasion",
            author: "Robert Cialdini",
            levelNumber: 3,
            dominantTopics: [.cognitiveBiases, .subconsciousProcesses],
            customTopics: ["Attention Anchoring", "Priming"],
            totalPages: 432,
            keyInsight: "The optimal persuasion technique occurs before the message is delivered by strategically anchoring attention.",
            gradientHexes: ["#0f172a", "#1d4ed8"]
        ),
        CurriculumMasterEntry(
            title: "Pitch Anything",
            author: "Oren Klaff",
            levelNumber: 3,
            dominantTopics: [.decisionMaking, .emotionalPsychology],
            customTopics: ["Frame Control", "Status Navigation"],
            totalPages: 240,
            keyInsight: "Using the neuroeconomic STRONG method to control interpersonal frames and establish commanding local status.",
            gradientHexes: ["#1e1b4b", "#c2410c"]
        ),
        CurriculumMasterEntry(
            title: "Never Split the Difference",
            author: "Chris Voss",
            levelNumber: 3,
            dominantTopics: [.emotionalPsychology, .humanBehaviour],
            customTopics: ["Tactical Empathy", "Calibrated Questions"],
            totalPages: 288,
            keyInsight: "FBI hostage negotiation tactics applied to business and life: tactical empathy, mirroring, and finding black swans.",
            gradientHexes: ["#111827", "#b91c1c"]
        ),
        CurriculumMasterEntry(
            title: "Win Bigly",
            author: "Scott Adams",
            levelNumber: 3,
            dominantTopics: [.cognitiveBiases, .mentalModels],
            customTopics: ["Cognitive Framing", "Persuasion Filters"],
            totalPages: 320,
            keyInsight: "Understanding persuasion in a world where facts do not matter and emotional frames dictate belief.",
            gradientHexes: ["#022c22", "#059669"]
        ),
        
        // Level 4: Micro-Expressions & Non-Verbal Signals
        CurriculumMasterEntry(
            title: "What Every BODY Is Saying",
            author: "Joe Navarro",
            levelNumber: 4,
            dominantTopics: [.humanBehaviour, .behaviouralPsychology],
            customTopics: ["Body Language", "Limbic Pacifiers"],
            totalPages: 272,
            keyInsight: "Former FBI agent reveals how to speed-read body language, spot limbic distress, and read unconscious baseline changes.",
            gradientHexes: ["#0f172a", "#3b82f6"]
        ),
        CurriculumMasterEntry(
            title: "Telling Lies",
            author: "Paul Ekman",
            levelNumber: 4,
            dominantTopics: [.emotionalPsychology, .humanBehaviour],
            customTopics: ["Micro-Expressions", "Deception Clues"],
            totalPages: 416,
            keyInsight: "The landmark scientific blueprint for decoding micro-facial expressions and the involuntary leakage of deceit.",
            gradientHexes: ["#18181b", "#701a75"]
        ),
        CurriculumMasterEntry(
            title: "Spy the Lie",
            author: "Philip Houston",
            levelNumber: 4,
            dominantTopics: [.cognitiveBiases, .decisionMaking],
            customTopics: ["CIA Interrogation", "Deception Detection"],
            totalPages: 272,
            keyInsight: "Former CIA polygraph and interrogation officers teach how to spot deception clusters within 5 seconds.",
            gradientHexes: ["#0f172a", "#0284c7"]
        ),
        CurriculumMasterEntry(
            title: "The Definitive Book of Body Language",
            author: "Allan & Barbara Pease",
            levelNumber: 4,
            dominantTopics: [.humanBehaviour, .subconsciousProcesses],
            customTopics: ["Kinesics", "Non-Verbal Cues"],
            totalPages: 400,
            keyInsight: "Comprehensive guide to body postures, hand gestures, gaze directions, and physical territoriality.",
            gradientHexes: ["#1e293b", "#4f46e5"]
        ),
        
        // Level 5: Deception & Psychological Countermeasures
        CurriculumMasterEntry(
            title: "The Confidence Game",
            author: "Maria Konnikova",
            levelNumber: 5,
            dominantTopics: [.cognitiveBiases, .subconsciousProcesses],
            customTopics: ["Con Artists", "Belief Manipulation"],
            totalPages: 352,
            keyInsight: "Dissects the con artist's psychological arc: the put-up, play, rope, touch, and blow-off.",
            gradientHexes: ["#1c1917", "#d97706"]
        ),
        CurriculumMasterEntry(
            title: "In Sheep's Clothing",
            author: "George K. Simon",
            levelNumber: 5,
            dominantTopics: [.humanBehaviour, .emotionalPsychology],
            customTopics: ["Covert Aggression", "Manipulation Tactics"],
            totalPages: 180,
            keyInsight: "Unmasks covert-aggressive personalities who hide hostile intent behind charm and victim manipulation.",
            gradientHexes: ["#1e1b4b", "#be123c"]
        ),
        CurriculumMasterEntry(
            title: "Gaslighting",
            author: "Stephanie Sarkis",
            levelNumber: 5,
            dominantTopics: [.emotionalPsychology, .behaviouralPsychology],
            customTopics: ["Gaslighting", "Psychological Defense"],
            totalPages: 240,
            keyInsight: "How malignant narcissists distort truth, erode reality, and establish totalitarian psychological control.",
            gradientHexes: ["#18181b", "#4c1d95"]
        ),
        
        // Level 6: Dark Triad & Machiavellian Strategy
        CurriculumMasterEntry(
            title: "The Prince",
            author: "Niccolò Machiavelli",
            levelNumber: 6,
            dominantTopics: [.humanBehaviour, .mentalModels],
            customTopics: ["Machiavellianism", "Power Politics"],
            totalPages: 140,
            keyInsight: "The foundational realism on holding power, statecraft, pragmatism, and ruthlessness over moral idealism.",
            gradientHexes: ["#262626", "#b91c1c"]
        ),
        CurriculumMasterEntry(
            title: "Snakes in Suits",
            author: "Paul Babiak & Robert D. Hare",
            levelNumber: 6,
            dominantTopics: [.humanBehaviour, .decisionMaking],
            customTopics: ["Corporate Psychopathy", "Dark Triad"],
            totalPages: 352,
            keyInsight: "How sub-clinical psychopaths charm, manipulate, and climb corporate hierarchies undetected.",
            gradientHexes: ["#0f172a", "#1e3a8a"]
        ),
        CurriculumMasterEntry(
            title: "The Psychopath Whisperer",
            author: "Kent A. Kiehl",
            levelNumber: 6,
            dominantTopics: [.cognitivePsychology, .subconsciousProcesses],
            customTopics: ["Neuroscience of Psychopathy", "Paralimbic System"],
            totalPages: 304,
            keyInsight: "MRI brain imaging and personal interviews detailing the emotional flatness and moral blindness of psychopaths.",
            gradientHexes: ["#18181b", "#374151"]
        ),
        CurriculumMasterEntry(
            title: "The Machiavellians: Defenders of Freedom",
            author: "James Burnham",
            levelNumber: 6,
            dominantTopics: [.mentalModels, .humanBehaviour],
            customTopics: ["Elite Theory", "Calculated Power"],
            totalPages: 240,
            keyInsight: "Analyzes Mosca, Pareto, and Michels on the iron law of oligarchy and ruling elites.",
            gradientHexes: ["#1c1917", "#78350f"]
        ),
        
        // Level 7: Ego Depletion & Emotional Exploitation
        CurriculumMasterEntry(
            title: "Willpower: Rediscovering the Greatest Human Strength",
            author: "Roy F. Baumeister",
            levelNumber: 7,
            dominantTopics: [.cognitivePsychology, .conditioningAndHabits],
            customTopics: ["Ego Depletion", "Vulnerability Windows"],
            totalPages: 304,
            keyInsight: "Mental energy and impulse control are finite resources that deplete, opening doors for exploitation.",
            gradientHexes: ["#1e1b4b", "#4338ca"]
        ),
        CurriculumMasterEntry(
            title: "Emotional Blackmail",
            author: "Susan Forward",
            levelNumber: 7,
            dominantTopics: [.emotionalPsychology, .humanBehaviour],
            customTopics: ["FOG Dynamics", "Boundary Defense"],
            totalPages: 256,
            keyInsight: "How manipulative people leverage Fear, Obligation, and Guilt (FOG) to compel compliance.",
            gradientHexes: ["#18181b", "#9f1239"]
        ),
        CurriculumMasterEntry(
            title: "Boundaries",
            author: "Henry Cloud & John Townsend",
            levelNumber: 7,
            dominantTopics: [.emotionalPsychology, .mentalModels],
            customTopics: ["Personal Sovereignty", "Boundaries"],
            totalPages: 320,
            keyInsight: "Where you end and another begins: essential framework for resisting psychological encroachment.",
            gradientHexes: ["#042f2e", "#0d9488"]
        ),
        
        // Level 8: Subliminal Conditioning & Cult Dynamics
        CurriculumMasterEntry(
            title: "Combatting Cult Mind Control",
            author: "Steven Hassan",
            levelNumber: 8,
            dominantTopics: [.subconsciousProcesses, .behaviouralPsychology],
            customTopics: ["BITE Model", "Cult Indoctrination"],
            totalPages: 256,
            keyInsight: "The BITE model: systematic control of Behavior, Information, Thought, and Emotion in coercive groups.",
            gradientHexes: ["#172554", "#1d4ed8"]
        ),
        CurriculumMasterEntry(
            title: "Cults Inside Out",
            author: "Rick Alan Ross",
            levelNumber: 8,
            dominantTopics: [.humanBehaviour, .subconsciousProcesses],
            customTopics: ["Mind Control", "Deprogramming"],
            totalPages: 600,
            keyInsight: "How destructive groups break down personal identity and reconstruct a compliant cult-bound persona.",
            gradientHexes: ["#1e1b4b", "#7e22ce"]
        ),
        CurriculumMasterEntry(
            title: "Subliminal",
            author: "Leonard Mlodinow",
            levelNumber: 8,
            dominantTopics: [.subconsciousProcesses, .cognitivePsychology],
            customTopics: ["Implicit Cognition", "Subliminal Triggers"],
            totalPages: 272,
            keyInsight: "Unconscious brain mechanisms that shape feelings, judgements, and social affiliations without awareness.",
            gradientHexes: ["#022c22", "#10b981"]
        ),
        
        // Level 9: Strategic Negotiation & Game Theory
        CurriculumMasterEntry(
            title: "Thinking in Bets",
            author: "Annie Duke",
            levelNumber: 9,
            dominantTopics: [.decisionMaking, .cognitiveBiases],
            customTopics: ["Probabilistic Thinking", "Adversarial Choices"],
            totalPages: 288,
            keyInsight: "Separating outcome quality from decision quality under conditions of uncertainty and deception.",
            gradientHexes: ["#1c1917", "#b45309"]
        ),
        CurriculumMasterEntry(
            title: "The Art of Strategy",
            author: "Avinash K. Dixit & Barry J. Nalebuff",
            levelNumber: 9,
            dominantTopics: [.mentalModels, .decisionMaking],
            customTopics: ["Game Theory", "Strategic Equilibrium"],
            totalPages: 512,
            keyInsight: "Game theory applied: backward induction, strategic moves, credible commitments, and Nash equilibria.",
            gradientHexes: ["#0f172a", "#0284c7"]
        ),
        CurriculumMasterEntry(
            title: "Getting to Yes",
            author: "Roger Fisher & William Ury",
            levelNumber: 9,
            dominantTopics: [.decisionMaking, .humanBehaviour],
            customTopics: ["Principled Negotiation", "BATNA"],
            totalPages: 224,
            keyInsight: "Negotiating agreement based on underlying interests, objective criteria, and BATNA rather than ego positions.",
            gradientHexes: ["#1e1b4b", "#4338ca"]
        ),
        
        // Level 10: The Master Synthesizer
        CurriculumMasterEntry(
            title: "Mastery",
            author: "Robert Greene",
            levelNumber: 10,
            dominantTopics: [.mentalModels, .conditioningAndHabits],
            customTopics: ["Supreme Mastery", "Synthesis"],
            totalPages: 352,
            keyInsight: "Attaining intuitive psychological mastery through apprenticeships, observational absorption, and creative synthesis.",
            gradientHexes: ["#000000", "#78350f"]
        ),
        CurriculumMasterEntry(
            title: "Antifragile",
            author: "Nassim Nicholas Taleb",
            levelNumber: 10,
            dominantTopics: [.mentalModels, .decisionMaking],
            customTopics: ["Antifragility", "Total Defense"],
            totalPages: 544,
            keyInsight: "Building psychological systems that actually grow and strengthen when subjected to volatility, stressors, and hostility.",
            gradientHexes: ["#09090b", "#14532d"]
        )
    ]
}
