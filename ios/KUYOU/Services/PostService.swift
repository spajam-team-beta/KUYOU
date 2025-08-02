import Foundation
import Combine

class PostService {
    static let shared = PostService()
    private init() {}
    
    func fetchPosts(
        page: Int = 1,
        perPage: Int = 10,
        category: String? = nil,
        sort: String = "recent"
    ) -> AnyPublisher<PostsResponse, APIError> {
        var path = "/posts?page=\(page)&per_page=\(perPage)&sort=\(sort)"
        if let category = category {
            path += "&category=\(category)"
        }
        
        return APIService.shared.request(
            path: path,
            method: "GET",
            authenticated: false,
            responseType: PostsResponse.self
        )
    }
    
    func fetchPost(id: Int) -> AnyPublisher<Post, APIError> {
        return APIService.shared.request(
            path: "/posts/\(id)",
            method: "GET",
            authenticated: false,
            responseType: [String: Post].self
        )
        .compactMap { $0["post"] }
        .eraseToAnyPublisher()
    }
    
    func createPost(content: String, category: String) -> AnyPublisher<PostResponse, APIError> {
        let request = CreatePostRequest(
            post: CreatePostRequest.PostData(
                content: content,
                category: category
            )
        )
        
        guard let body = try? APIService.shared.encode(request) else {
            return Fail(error: APIError.decodingError)
                .eraseToAnyPublisher()
        }
        
        return APIService.shared.request(
            path: "/posts",
            method: "POST",
            body: body,
            responseType: PostResponse.self
        )
    }
    
    func addSympathy(postId: Int) -> AnyPublisher<SympathyResponse, APIError> {
        return APIService.shared.request(
            path: "/posts/\(postId)/sympathies",
            method: "POST",
            responseType: SympathyResponse.self
        )
    }
    
    func removeSympathy(postId: Int) -> AnyPublisher<SympathyResponse, APIError> {
        return APIService.shared.request(
            path: "/posts/\(postId)/sympathies",
            method: "DELETE",
            responseType: SympathyResponse.self
        )
    }
}