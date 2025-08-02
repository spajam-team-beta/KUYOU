import Foundation
import Combine

class CreatePostViewModel: ObservableObject {
    @Published var content = ""
    @Published var selectedCategory: PostCategory = .other
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let postService = PostService.shared
    
    var canPost: Bool {
        !content.isEmpty && content.count <= 1000 && !isLoading
    }
    
    func createPost(completion: @escaping () -> Void) {
        guard canPost else { return }
        
        isLoading = true
        errorMessage = nil
        
        postService.createPost(
            content: content,
            category: selectedCategory.rawValue
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] result in
                self?.isLoading = false
                if case .failure(let error) = result {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { response in
                // Show success message if needed
                print("Post created successfully! Points earned: \(response.pointsEarned ?? 0)")
                completion()
            }
        )
        .store(in: &cancellables)
    }
}