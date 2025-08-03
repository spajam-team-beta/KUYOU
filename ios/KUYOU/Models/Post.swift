import Foundation

struct Post: Codable, Identifiable {
    let id: Int
    let nickname: String
    let content: String
    let category: String
    let status: String
    var sympathyCount: Int
    let replyCount: Int
    var isResolved: Bool
    let isMine: Bool?
    var hasSympathized: Bool?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case nickname
        case content
        case category
        case status
        case sympathyCount = "sympathy_count"
        case replyCount = "reply_count"  
        case isResolved = "is_resolved"
        case isMine = "is_mine"
        case hasSympathized = "has_sympathized"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        nickname = try container.decode(String.self, forKey: .nickname)
        content = try container.decode(String.self, forKey: .content)
        category = try container.decode(String.self, forKey: .category)
        status = try container.decode(String.self, forKey: .status)
        sympathyCount = try container.decode(Int.self, forKey: .sympathyCount)
        replyCount = try container.decode(Int.self, forKey: .replyCount)
        isResolved = try container.decode(Bool.self, forKey: .isResolved)
        isMine = try container.decodeIfPresent(Bool.self, forKey: .isMine)
        hasSympathized = try container.decodeIfPresent(Bool.self, forKey: .hasSympathized)
        
        // カスタム日付デコード
        createdAt = try DateUtils.decodeDate(from: container, forKey: .createdAt)
        updatedAt = try DateUtils.decodeDate(from: container, forKey: .updatedAt)
    }
}

struct PostsResponse: Codable {
    let posts: [Post]
    let meta: PaginationMeta
}

struct PaginationMeta: Codable {
    let currentPage: Int
    let totalPages: Int
    let totalCount: Int
    let perPage: Int
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case totalPages = "total_pages"
        case totalCount = "total_count"
        case perPage = "per_page"
    }
}

struct CreatePostRequest: Codable {
    let post: PostData
    
    struct PostData: Codable {
        let content: String
        let category: String
    }
}

struct PostResponse: Codable {
    let post: Post
    let pointsEarned: Int?
    
    enum CodingKeys: String, CodingKey {
        case post
        case pointsEarned = "points_earned"
    }
}

enum PostCategory: String, CaseIterable {
    case love = "love"
    case work = "work"
    case school = "school"
    case family = "family"
    case friend = "friend"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .love: return "恋愛"
        case .work: return "仕事"
        case .school: return "学生時代"
        case .family: return "家族"
        case .friend: return "友人"
        case .other: return "その他"
        }
    }
}
