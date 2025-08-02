import Foundation

enum Achievement: String, CaseIterable, Codable {
    case firstPost = "初めての告白"
    case tenSalvations = "供養師見習い"
    case hundredSalvations = "供養師"
    case thousandSalvations = "供養師匠"
    case firstBestAnswer = "初めての成仏"
    case tenBestAnswers = "導師"
    case comedyMaster = "爆笑の達人"
    case touchingMaster = "感動の達人"
    case philosophyMaster = "哲学の達人"
    
    var icon: String {
        switch self {
        case .firstPost: return "pencil.circle.fill"
        case .tenSalvations, .hundredSalvations, .thousandSalvations: return "hands.sparkles.fill"
        case .firstBestAnswer, .tenBestAnswers: return "star.circle.fill"
        case .comedyMaster: return "face.smiling.fill"
        case .touchingMaster: return "heart.fill"
        case .philosophyMaster: return "brain"
        }
    }
    
    var requiredPoints: Int {
        switch self {
        case .firstPost: return 0
        case .tenSalvations: return 10
        case .hundredSalvations: return 100
        case .thousandSalvations: return 1000
        case .firstBestAnswer: return 0
        case .tenBestAnswers: return 0
        case .comedyMaster: return 500
        case .touchingMaster: return 500
        case .philosophyMaster: return 500
        }
    }
}

struct UserModel: Codable {
    let id: UUID
    var totalPoints: Int
    var postedHistories: [UUID]
    var achievements: Set<Achievement>
    var salvationGiven: Int
    var bestAnswersReceived: Int
    var lastActiveDate: Date
    
    init(
        id: UUID = UUID(),
        totalPoints: Int = 0,
        postedHistories: [UUID] = [],
        achievements: Set<Achievement> = [],
        salvationGiven: Int = 0,
        bestAnswersReceived: Int = 0,
        lastActiveDate: Date = Date()
    ) {
        self.id = id
        self.totalPoints = totalPoints
        self.postedHistories = postedHistories
        self.achievements = achievements
        self.salvationGiven = salvationGiven
        self.bestAnswersReceived = bestAnswersReceived
        self.lastActiveDate = lastActiveDate
    }
    
    mutating func addPoints(_ points: Int) {
        totalPoints += points
        checkAchievements()
    }
    
    mutating func checkAchievements() {
        if !postedHistories.isEmpty && !achievements.contains(.firstPost) {
            achievements.insert(.firstPost)
        }
        
        if salvationGiven >= 10 {
            achievements.insert(.tenSalvations)
        }
        if salvationGiven >= 100 {
            achievements.insert(.hundredSalvations)
        }
        if salvationGiven >= 1000 {
            achievements.insert(.thousandSalvations)
        }
        
        if bestAnswersReceived >= 1 {
            achievements.insert(.firstBestAnswer)
        }
        if bestAnswersReceived >= 10 {
            achievements.insert(.tenBestAnswers)
        }
    }
}

struct PointsConstants {
    static let postBlackHistory = 10
    static let receiveSalvation = 1
    static let giveSalvation = 2
    static let postRewrite = 5
    static let receiveLike = 1
    static let receiveBestAnswer = 50
}