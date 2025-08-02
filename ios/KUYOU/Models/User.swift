import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let totalPoints: Int
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case totalPoints = "total_points"
        case createdAt = "created_at"
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