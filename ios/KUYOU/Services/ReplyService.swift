import Foundation
import Combine

struct BestReplyResponse: Decodable {
    let success: Bool?
}

class ReplyService {
    static let shared = ReplyService()
    private init() {}
    
    func fetchReplies(postId: Int) -> AnyPublisher<RepliesResponse, APIError> {
        return APIService.shared.request(
            path: "/posts/\(postId)/replies",
            method: "GET",
            responseType: RepliesResponse.self
        )
    }
    
    func createReply(postId: Int, content: String) -> AnyPublisher<ReplyResponse, APIError> {
        let request = CreateReplyRequest(
            reply: CreateReplyRequest.ReplyData(content: content)
        )
        
        guard let body = try? APIService.shared.encode(request) else {
            return Fail(error: APIError.decodingError)
                .eraseToAnyPublisher()
        }
        
        return APIService.shared.request(
            path: "/posts/\(postId)/replies",
            method: "POST",
            body: body,
            responseType: ReplyResponse.self
        )
    }
    
    func selectBestReply(postId: Int, replyId: Int) -> AnyPublisher<BestReplyResponse, APIError> {
        return APIService.shared.request(
            path: "/posts/\(postId)/replies/\(replyId)/select_best",
            method: "PATCH",
            responseType: BestReplyResponse.self
        )
    }
}