import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var user: UserModel
    @Published var myHistories: [BlackHistoryModel] = []
    @Published var isLoading: Bool = false
    
    private let storageService = StorageService.shared
    
    init() {
        self.user = storageService.loadUser()
        loadMyHistories()
    }
    
    func loadMyHistories() {
        isLoading = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let allHistories = self.storageService.loadAllBlackHistories()
            self.myHistories = allHistories.filter { history in
                self.user.postedHistories.contains(history.id)
            }
            
            self.isLoading = false
        }
    }
    
    func refresh() {
        user = storageService.loadUser()
        loadMyHistories()
    }
    
    var levelTitle: String {
        switch user.totalPoints {
        case 0..<100:
            return "初心者"
        case 100..<500:
            return "見習い"
        case 500..<1000:
            return "供養師"
        case 1000..<5000:
            return "供養師匠"
        case 5000..<10000:
            return "大供養師"
        default:
            return "供養大師"
        }
    }
    
    var nextLevelPoints: Int {
        switch user.totalPoints {
        case 0..<100:
            return 100
        case 100..<500:
            return 500
        case 500..<1000:
            return 1000
        case 1000..<5000:
            return 5000
        case 5000..<10000:
            return 10000
        default:
            return user.totalPoints + 5000
        }
    }
    
    var levelProgress: Double {
        let currentLevelStart: Int
        switch user.totalPoints {
        case 0..<100:
            currentLevelStart = 0
        case 100..<500:
            currentLevelStart = 100
        case 500..<1000:
            currentLevelStart = 500
        case 1000..<5000:
            currentLevelStart = 1000
        case 5000..<10000:
            currentLevelStart = 5000
        default:
            currentLevelStart = 10000
        }
        
        let progress = Double(user.totalPoints - currentLevelStart) / Double(nextLevelPoints - currentLevelStart)
        return min(max(progress, 0), 1)
    }
    
    var sortedAchievements: [Achievement] {
        user.achievements.sorted { achievement1, achievement2 in
            achievement1.rawValue < achievement2.rawValue
        }
    }
    
    var unlockedAchievements: [Achievement] {
        Achievement.allCases.filter { user.achievements.contains($0) }
    }
    
    var lockedAchievements: [Achievement] {
        Achievement.allCases.filter { !user.achievements.contains($0) }
    }
}