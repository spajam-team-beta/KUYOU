import Foundation
import Combine

class TimelineViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var selectedCategory: PostCategory?
    @Published var selectedSort: SortOption = .recent
    @Published var searchText = ""
    @Published var isSearching = false
    
    private var currentPage = 1
    private var totalPages = 1
    private var cancellables = Set<AnyCancellable>()
    private let postService = PostService.shared
    private var autoRefreshTimer: Timer?
    
    init() {
        setupNotificationObservers()
        setupSearchObserver()
    }
    
    private func setupNotificationObservers() {
        // Listen for post creation
        NotificationCenter.default.publisher(for: .postCreated)
            .sink { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.checkForUpdates()
                }
            }
            .store(in: &cancellables)
        
        // Listen for reply creation
        NotificationCenter.default.publisher(for: .replyCreated)
            .sink { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.checkForUpdates()
                }
            }
            .store(in: &cancellables)
        
        // Listen for sympathy updates
        NotificationCenter.default.publisher(for: .sympathyUpdated)
            .sink { [weak self] notification in
                if let postId = notification.userInfo?["postId"] as? Int {
                    self?.refreshPostData(postId: postId)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupSearchObserver() {
        // Debounce search text changes
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.performSearch(keyword: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(keyword: String) {
        isSearching = !keyword.isEmpty
        loadPosts(refresh: true)
    }
    
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
            sort: selectedSort.rawValue,
            keyword: searchText.isEmpty ? nil : searchText
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
                    
                    // Notify other parts of the app about the sympathy update
                    NotificationService.shared.sympathyUpdated(postId: post.id)
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
    
    func clearSearch() {
        searchText = ""
    }
    
    // Auto-refresh when posts change
    func refreshFromBackground() {
        loadPosts(refresh: true)
    }
    
    // Check for new posts without showing loading indicator
    func checkForUpdates() {
        postService.fetchPosts(
            page: 1,
            category: selectedCategory?.rawValue,
            sort: selectedSort.rawValue,
            keyword: searchText.isEmpty ? nil : searchText
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                guard let self = self else { return }
                let newPosts = response.posts
                
                // Check if we have new posts
                if !newPosts.isEmpty && (self.posts.isEmpty || newPosts.first?.id != self.posts.first?.id) {
                    // Insert new posts at the beginning
                    let uniqueNewPosts = newPosts.filter { newPost in
                        !self.posts.contains { $0.id == newPost.id }
                    }
                    self.posts = uniqueNewPosts + self.posts
                }
            }
        )
        .store(in: &cancellables)
    }
    
    // Refresh specific post data
    private func refreshPostData(postId: Int) {
        // Just check for updates to refresh the entire list
        // This ensures we get the latest data for all posts
        checkForUpdates()
    }
}