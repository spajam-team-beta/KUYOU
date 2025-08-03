import Foundation
import Combine

// Notification names
extension Notification.Name {
    static let postCreated = Notification.Name("postCreated")
    static let postUpdated = Notification.Name("postUpdated")
    static let replyCreated = Notification.Name("replyCreated")
    static let sympathyUpdated = Notification.Name("sympathyUpdated")
}

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    private init() {}
    
    // Post notifications
    func postCreated() {
        NotificationCenter.default.post(name: .postCreated, object: nil)
    }
    
    func postUpdated(postId: Int) {
        NotificationCenter.default.post(name: .postUpdated, object: nil, userInfo: ["postId": postId])
    }
    
    func replyCreated(postId: Int) {
        NotificationCenter.default.post(name: .replyCreated, object: nil, userInfo: ["postId": postId])
    }
    
    func sympathyUpdated(postId: Int) {
        NotificationCenter.default.post(name: .sympathyUpdated, object: nil, userInfo: ["postId": postId])
    }
}

