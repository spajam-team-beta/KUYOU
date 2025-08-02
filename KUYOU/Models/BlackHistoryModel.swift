import Foundation

enum Category: String, CaseIterable, Codable {
    case love = "恋愛"
    case chuunibyou = "中二病"
    case sns = "SNS"
    case school = "学校生活"
    case family = "家族"
    case other = "その他"
    
    var icon: String {
        switch self {
        case .love: return "heart.fill"
        case .chuunibyou: return "sparkles"
        case .sns: return "bubble.left.fill"
        case .school: return "graduationcap.fill"
        case .family: return "house.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

enum EmotionTag: String, CaseIterable, Codable {
    case maxEmbarrassment = "赤面レベルMAX"
    case wantToRewind = "時を戻したい"
    case ratherProud = "むしろ誇り"
    case helpMe = "誰か助けて"
    
    var color: String {
        switch self {
        case .maxEmbarrassment: return "red"
        case .wantToRewind: return "purple"
        case .ratherProud: return "orange"
        case .helpMe: return "blue"
        }
    }
}

struct BlackHistoryModel: Identifiable, Codable {
    let id: UUID
    let content: String
    let category: Category
    let emotionTags: [EmotionTag]
    let createdAt: Date
    var salvationCount: Int
    var isResolved: Bool
    var bestAnswerId: UUID?
    
    init(
        id: UUID = UUID(),
        content: String,
        category: Category,
        emotionTags: [EmotionTag],
        createdAt: Date = Date(),
        salvationCount: Int = 0,
        isResolved: Bool = false,
        bestAnswerId: UUID? = nil
    ) {
        self.id = id
        self.content = content
        self.category = category
        self.emotionTags = emotionTags
        self.createdAt = createdAt
        self.salvationCount = salvationCount
        self.isResolved = isResolved
        self.bestAnswerId = bestAnswerId
    }
}

extension BlackHistoryModel {
    static var mockData: [BlackHistoryModel] {
        [
            BlackHistoryModel(
                content: "中学時代、教室で堂々と「我は闇の支配者...」とか言ってた。今思い出すと布団の中で叫びたくなる。",
                category: .chuunibyou,
                emotionTags: [.maxEmbarrassment, .wantToRewind],
                salvationCount: 42
            ),
            BlackHistoryModel(
                content: "好きな人のSNSを深夜に全部遡って見てたら、3年前の投稿に間違えていいねしてしまった...",
                category: .love,
                emotionTags: [.helpMe, .maxEmbarrassment],
                salvationCount: 108
            ),
            BlackHistoryModel(
                content: "家族旅行の写真をSNSに投稿する時、顔にスタンプ付け忘れて母の変顔が全世界に公開された",
                category: .family,
                emotionTags: [.wantToRewind],
                salvationCount: 33
            )
        ]
    }
}