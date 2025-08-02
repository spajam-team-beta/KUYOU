import Foundation
import Combine

class PostDetailViewModel: ObservableObject {
    @Published var post: Post?
    @Published var replies: [Reply] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var postId: Int = 0
    private var cancellables = Set<AnyCancellable>()
    private let postService = PostService.shared
    private let replyService = ReplyService.shared
    
    func loadPost() {
        isLoading = true
        errorMessage = nil
        
        postService.fetchPost(id: postId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] post in
                    self?.post = post
                    self?.loadReplies()
                }
            )
            .store(in: &cancellables)
    }
    
    func loadReplies() {
        replyService.fetchReplies(postId: postId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to load replies: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.replies = response.replies
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleSympathy() {
        guard let post = post,
              AuthService.shared.isAuthenticated else { return }
        
        let hasAlreadySympathized = post.hasSympathized ?? false
        let publisher = hasAlreadySympathized
            ? postService.removeSympathy(postId: post.id)
            : postService.addSympathy(postId: post.id)
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Sympathy error: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.post?.sympathyCount = response.sympathyCount
                    self?.post?.hasSympathized = !hasAlreadySympathized
                }
            )
            .store(in: &cancellables)
    }
    
    func selectBestReply(_ reply: Reply) {
        replyService.selectBestReply(postId: postId, replyId: reply.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.post?.isResolved = true
                    self?.loadPost() // Reload to get updated state
                }
            )
            .store(in: &cancellables)
    }
}