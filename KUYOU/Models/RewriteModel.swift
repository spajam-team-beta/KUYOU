import Foundation

enum RewriteRoute: String, CaseIterable, Codable {
    case comedy = "爆笑ルート"
    case touching = "感動ルート"
    case philosophy = "真理ルート"
    
    var icon: String {
        switch self {
        case .comedy: return "face.smiling.fill"
        case .touching: return "heart.circle.fill"
        case .philosophy: return "lightbulb.fill"
        }
    }
    
    var color: String {
        switch self {
        case .comedy: return "yellow"
        case .touching: return "pink"
        case .philosophy: return "indigo"
        }
    }
}

struct RewriteModel: Identifiable, Codable {
    let id: UUID
    let blackHistoryId: UUID
    let content: String
    let route: RewriteRoute
    let createdAt: Date
    var likeCount: Int
    var isBestAnswer: Bool
    
    init(
        id: UUID = UUID(),
        blackHistoryId: UUID,
        content: String,
        route: RewriteRoute,
        createdAt: Date = Date(),
        likeCount: Int = 0,
        isBestAnswer: Bool = false
    ) {
        self.id = id
        self.blackHistoryId = blackHistoryId
        self.content = content
        self.route = route
        self.createdAt = createdAt
        self.likeCount = likeCount
        self.isBestAnswer = isBestAnswer
    }
}

extension RewriteModel {
    static func mockData(for blackHistoryId: UUID) -> [RewriteModel] {
        [
            RewriteModel(
                blackHistoryId: blackHistoryId,
                content: "その瞬間、教室に新たな伝説が生まれた。後に「闇の支配者事件」として語り継がれることになる...",
                route: .comedy,
                likeCount: 24
            ),
            RewriteModel(
                blackHistoryId: blackHistoryId,
                content: "純粋な想像力と表現への情熱。大人になって失われがちな、あの頃の自由な心を持っていた証拠です。",
                route: .touching,
                likeCount: 15
            ),
            RewriteModel(
                blackHistoryId: blackHistoryId,
                content: "人は皆、内なる闇と光を抱えている。それを表現する勇気は、実は多くの人が持てないもの。",
                route: .philosophy,
                likeCount: 18,
                isBestAnswer: true
            )
        ]
    }
}