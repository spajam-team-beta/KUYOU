import Foundation
import Combine

class TimelineViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var selectedCategory: PostCategory?
    @Published var selectedSort: SortOption = .recent
    
    private var currentPage = 1
    private var totalPages = 1
    private var cancellables = Set<AnyCancellable>()
    private let postService = PostService.shared
    
    enum SortOption: String, CaseIterable {
        case recent = "recent"
        case popular = "popular"
        
        var displayName: String {
            switch self {
            case .recent: return "新着順"
            case .popular: return "人気順"
            }
        }
    }
    
    func loadPosts(refresh: Bool = false) {
        guard !isLoading else { return }
        
        if refresh {
            currentPage = 1
            posts = []
        }
        
        isLoading = true
        errorMessage = nil
        
        postService.fetchPosts(
            page: currentPage,
            category: selectedCategory?.rawValue,
            sort: selectedSort.rawValue
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { [weak self] response in
                if refresh {
                    self?.posts = response.posts
                } else {
                    self?.posts.append(contentsOf: response.posts)
                }
                self?.totalPages = response.meta.totalPages
                self?.currentPage += 1
            }
        )
        .store(in: &cancellables)
    }
    
    func loadMoreIfNeeded(post: Post) {
        guard let lastPost = posts.last,
              lastPost.id == post.id,
              currentPage <= totalPages,
              !isLoadingMore else { return }
        
        isLoadingMore = true
        loadPosts()
    }
    
    func toggleSympathy(for post: Post) {
        guard AuthService.shared.isAuthenticated else { return }
        
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
                    self?.updatePost(postId: post.id) { post in
                        var updatedPost = post
                        updatedPost.sympathyCount = response.sympathyCount
                        updatedPost.hasSympathized = !hasAlreadySympathized
                        return updatedPost
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func updatePost(postId: Int, transform: (Post) -> Post) {
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index] = transform(posts[index])
        }
    }
    
    func changeCategory(_ category: PostCategory?) {
        selectedCategory = category
        loadPosts(refresh: true)
    }
    
    func changeSort(_ sort: SortOption) {
        selectedSort = sort
        loadPosts(refresh: true)
    }
}