import Foundation

struct SympathyResponse: Codable {
    let sympathyCount: Int
    let pointsEarned: Int?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case sympathyCount = "sympathy_count"
        case pointsEarned = "points_earned"
        case message
    }
}