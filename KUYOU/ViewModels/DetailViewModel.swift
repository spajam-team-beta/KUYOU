import SwiftUI
import Combine

class DetailViewModel: ObservableObject {
    @Published var blackHistory: BlackHistoryModel
    @Published var rewrites: [RewriteModel] = []
    @Published var isLoadingRewrites: Bool = false
    @Published var showRewriteSheet: Bool = false
    @Published var rewriteContent: String = ""
    @Published var selectedRoute: RewriteRoute = .comedy
    @Published var showAscensionEffect: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    private let storageService = StorageService.shared
    private let contentFilter = ContentFilter.shared
    private let audioService = AudioService.shared
    
    init(blackHistory: BlackHistoryModel) {
        self.blackHistory = blackHistory
        loadRewrites()
    }
    
    func loadRewrites() {
        isLoadingRewrites = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.rewrites = self.storageService.loadRewrites(for: self.blackHistory.id)
            self.isLoadingRewrites = false
        }
    }
    
    func submitRewrite() {
        let sanitizedContent = contentFilter.sanitize(rewriteContent)
        
        switch contentFilter.validate(sanitizedContent) {
        case .success:
            let rewrite = RewriteModel(
                blackHistoryId: blackHistory.id,
                content: sanitizedContent,
                route: selectedRoute
            )
            
            do {
                try storageService.saveRewrite(rewrite)
                
                var user = storageService.loadUser()
                user.addPoints(PointsConstants.postRewrite)
                try storageService.saveUser(user)
                
                loadRewrites()
                rewriteContent = ""
                showRewriteSheet = false
                
            } catch {
                showError(message: "リライト案の保存に失敗しました")
            }
            
        case .failure(let error):
            showError(message: error.localizedDescription)
        }
    }
    
    func likeRewrite(_ rewrite: RewriteModel) {
        var updatedRewrite = rewrite
        updatedRewrite.likeCount += 1
        
        do {
            try storageService.updateRewrite(updatedRewrite)
            
            if let index = rewrites.firstIndex(where: { $0.id == rewrite.id }) {
                rewrites[index] = updatedRewrite
            }
        } catch {
            print("Failed to like rewrite: \(error)")
        }
    }
    
    func selectBestAnswer(_ rewrite: RewriteModel) {
        guard !blackHistory.isResolved else { return }
        
        var updatedRewrite = rewrite
        updatedRewrite.isBestAnswer = true
        
        blackHistory.isResolved = true
        blackHistory.bestAnswerId = rewrite.id
        
        do {
            try storageService.updateRewrite(updatedRewrite)
            try storageService.updateBlackHistory(blackHistory)
            
            var user = storageService.loadUser()
            user.bestAnswersReceived += 1
            user.addPoints(PointsConstants.receiveBestAnswer)
            try storageService.saveUser(user)
            
            showAscensionEffect = true
            audioService.playAscension()
            
            if let index = rewrites.firstIndex(where: { $0.id == rewrite.id }) {
                rewrites[index] = updatedRewrite
            }
            
        } catch {
            showError(message: "ベストアンサーの選択に失敗しました")
        }
    }
    
    func giveSalvation() {
        blackHistory.salvationCount += 1
        
        do {
            try storageService.updateBlackHistory(blackHistory)
            
            var user = storageService.loadUser()
            user.salvationGiven += 1
            user.addPoints(PointsConstants.giveSalvation)
            try storageService.saveUser(user)
            
            audioService.playMokugyo()
            
        } catch {
            print("Failed to save salvation: \(error)")
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    var canSubmitRewrite: Bool {
        !rewriteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var remainingCharacters: Int {
        300 - rewriteContent.count
    }
}