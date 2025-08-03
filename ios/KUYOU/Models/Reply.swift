import Foundation

struct Reply: Codable, Identifiable {
    let id: Int
    let content: String
    let isBest: Bool
    let userNickname: String
    let isMine: Bool?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case isBest = "is_best"
        case userNickname = "user_nickname"
        case isMine = "is_mine"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        isBest = try container.decode(Bool.self, forKey: .isBest)
        userNickname = try container.decode(String.self, forKey: .userNickname)
        isMine = try container.decodeIfPresent(Bool.self, forKey: .isMine)
        
        // カスタム日付デコード
        createdAt = try DateUtils.decodeDate(from: container, forKey: .createdAt)
        updatedAt = try DateUtils.decodeDate(from: container, forKey: .updatedAt)
    }
}

struct RepliesResponse: Codable {
    let replies: [Reply]
}

struct CreateReplyRequest: Codable {
    let reply: ReplyData
    
    struct ReplyData: Codable {
        let content: String
    }
}

struct ReplyResponse: Codable {
    let reply: Reply
    let pointsEarned: Int?
    
    enum CodingKeys: String, CodingKey {
        case reply
        case pointsEarned = "points_earned"
    }
}
