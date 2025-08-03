import Foundation

struct User: Codable, Identifiable {
    var id: Int
    var email: String
   var nickname: String?
    var totalPoints: Int
    var createdAt: Date
    
    var displayNickname: String {
        return nickname?.isEmpty == false ? nickname! : "智者#\(String(format: "%04d", id))"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case nickname
        case totalPoints = "total_points"
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        totalPoints = try container.decode(Int.self, forKey: .totalPoints)
        
        // カスタム日付デコード
        createdAt = try DateUtils.decodeDate(from: container, forKey: .createdAt)
    }
}

struct AuthResponse: Codable {
    let user: UserData
    let token: String
    
    struct UserData: Codable {
        let data: UserAttributes
        
        struct UserAttributes: Codable {
            let attributes: User
        }
    }
}

struct LoginRequest: Codable {
    let user: LoginData
    
    struct LoginData: Codable {
        let email: String
        let password: String
    }
}

struct RegisterRequest: Codable {
    let user: RegisterData
    
    struct RegisterData: Codable {
        let email: String
        let password: String
        let passwordConfirmation: String
        
        enum CodingKeys: String, CodingKey {
            case email
            case password
            case passwordConfirmation = "password_confirmation"
        }
    }
}
