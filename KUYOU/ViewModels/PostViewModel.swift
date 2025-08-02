import SwiftUI
import Combine

class PostViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var selectedCategory: Category = .other
    @Published var selectedEmotionTags: Set<EmotionTag> = []
    @Published var isPosting: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showSuccessAnimation: Bool = false
    
    private let storageService = StorageService.shared
    private let contentFilter = ContentFilter.shared
    private var cancellables = Set<AnyCancellable>()
    
    var canPost: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedEmotionTags.isEmpty &&
        !isPosting
    }
    
    var remainingCharacters: Int {
        500 - content.count
    }
    
    func toggleEmotionTag(_ tag: EmotionTag) {
        if selectedEmotionTags.contains(tag) {
            selectedEmotionTags.remove(tag)
        } else {
            if selectedEmotionTags.count < 3 {
                selectedEmotionTags.insert(tag)
            }
        }
    }
    
    func post() {
        guard canPost else { return }
        
        isPosting = true
        
        let sanitizedContent = contentFilter.sanitize(content)
        
        switch contentFilter.validate(sanitizedContent) {
        case .success:
            let blackHistory = BlackHistoryModel(
                content: sanitizedContent,
                category: selectedCategory,
                emotionTags: Array(selectedEmotionTags)
            )
            
            do {
                try storageService.saveBlackHistory(blackHistory)
                
                var user = storageService.loadUser()
                user.postedHistories.append(blackHistory.id)
                user.addPoints(PointsConstants.postBlackHistory)
                try storageService.saveUser(user)
                
                showSuccessAnimation = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.resetForm()
                    self.isPosting = false
                }
                
            } catch {
                showError(message: "投稿の保存に失敗しました")
                isPosting = false
            }
            
        case .failure(let error):
            showError(message: error.localizedDescription)
            isPosting = false
        }
    }
    
    private func resetForm() {
        content = ""
        selectedCategory = .other
        selectedEmotionTags = []
        showSuccessAnimation = false
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}