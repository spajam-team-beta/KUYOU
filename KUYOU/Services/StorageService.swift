import Foundation

protocol StorageServiceProtocol {
    func saveBlackHistory(_ history: BlackHistoryModel) throws
    func loadAllBlackHistories() -> [BlackHistoryModel]
    func loadBlackHistory(by id: UUID) -> BlackHistoryModel?
    func updateBlackHistory(_ history: BlackHistoryModel) throws
    
    func saveRewrite(_ rewrite: RewriteModel) throws
    func loadRewrites(for blackHistoryId: UUID) -> [RewriteModel]
    func updateRewrite(_ rewrite: RewriteModel) throws
    
    func loadUser() -> UserModel
    func saveUser(_ user: UserModel) throws
}

class StorageService: StorageServiceProtocol {
    static let shared = StorageService()
    
    private let userDefaults = UserDefaults.standard
    
    private let blackHistoriesKey = "com.kuyou.blackHistories"
    private let rewritesKey = "com.kuyou.rewrites"
    private let userKey = "com.kuyou.user"
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    func saveBlackHistory(_ history: BlackHistoryModel) throws {
        var histories = loadAllBlackHistories()
        
        if let index = histories.firstIndex(where: { $0.id == history.id }) {
            histories[index] = history
        } else {
            histories.insert(history, at: 0)
        }
        
        let data = try encoder.encode(histories)
        userDefaults.set(data, forKey: blackHistoriesKey)
    }
    
    func loadAllBlackHistories() -> [BlackHistoryModel] {
        guard let data = userDefaults.data(forKey: blackHistoriesKey),
              let histories = try? decoder.decode([BlackHistoryModel].self, from: data) else {
            return []
        }
        return histories
    }
    
    func loadBlackHistory(by id: UUID) -> BlackHistoryModel? {
        return loadAllBlackHistories().first { $0.id == id }
    }
    
    func updateBlackHistory(_ history: BlackHistoryModel) throws {
        try saveBlackHistory(history)
    }
    
    func saveRewrite(_ rewrite: RewriteModel) throws {
        var rewrites = loadAllRewrites()
        
        if let index = rewrites.firstIndex(where: { $0.id == rewrite.id }) {
            rewrites[index] = rewrite
        } else {
            rewrites.append(rewrite)
        }
        
        let data = try encoder.encode(rewrites)
        userDefaults.set(data, forKey: rewritesKey)
    }
    
    func loadRewrites(for blackHistoryId: UUID) -> [RewriteModel] {
        return loadAllRewrites()
            .filter { $0.blackHistoryId == blackHistoryId }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func updateRewrite(_ rewrite: RewriteModel) throws {
        try saveRewrite(rewrite)
    }
    
    func loadUser() -> UserModel {
        guard let data = userDefaults.data(forKey: userKey),
              let user = try? decoder.decode(UserModel.self, from: data) else {
            return UserModel()
        }
        return user
    }
    
    func saveUser(_ user: UserModel) throws {
        let data = try encoder.encode(user)
        userDefaults.set(data, forKey: userKey)
    }
    
    private func loadAllRewrites() -> [RewriteModel] {
        guard let data = userDefaults.data(forKey: rewritesKey),
              let rewrites = try? decoder.decode([RewriteModel].self, from: data) else {
            return []
        }
        return rewrites
    }
    
    func clearAllData() {
        userDefaults.removeObject(forKey: blackHistoriesKey)
        userDefaults.removeObject(forKey: rewritesKey)
        userDefaults.removeObject(forKey: userKey)
    }
    
    #if DEBUG
    func loadMockData() {
        let mockHistories = BlackHistoryModel.mockData
        if let data = try? encoder.encode(mockHistories) {
            userDefaults.set(data, forKey: blackHistoriesKey)
        }
        
        var mockRewrites: [RewriteModel] = []
        for history in mockHistories {
            mockRewrites.append(contentsOf: RewriteModel.mockData(for: history.id))
        }
        if let data = try? encoder.encode(mockRewrites) {
            userDefaults.set(data, forKey: rewritesKey)
        }
    }
    #endif
}