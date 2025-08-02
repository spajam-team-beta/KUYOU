import SwiftUI
import Combine

enum SortOption: String, CaseIterable {
    case newest = "新着順"
    case popular = "人気順"
    case resolved = "成仏済み"
    
    var icon: String {
        switch self {
        case .newest: return "clock.fill"
        case .popular: return "flame.fill"
        case .resolved: return "checkmark.seal.fill"
        }
    }
}

class TimelineViewModel: ObservableObject {
    @Published var blackHistories: [BlackHistoryModel] = []
    @Published var filteredHistories: [BlackHistoryModel] = []
    @Published var selectedCategory: Category?
    @Published var sortOption: SortOption = .newest
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    
    private let storageService = StorageService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadBlackHistories()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest3($selectedCategory, $sortOption, $searchText)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyFiltersAndSort()
            }
            .store(in: &cancellables)
    }
    
    func loadBlackHistories() {
        isLoading = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.blackHistories = self.storageService.loadAllBlackHistories()
            self.applyFiltersAndSort()
            self.isLoading = false
        }
    }
    
    func refresh() {
        loadBlackHistories()
    }
    
    private func applyFiltersAndSort() {
        var filtered = blackHistories
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { history in
                history.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch sortOption {
        case .newest:
            filtered.sort { $0.createdAt > $1.createdAt }
        case .popular:
            filtered.sort { $0.salvationCount > $1.salvationCount }
        case .resolved:
            filtered = filtered.filter { $0.isResolved }
            filtered.sort { $0.createdAt > $1.createdAt }
        }
        
        filteredHistories = filtered
    }
    
    func giveSalvation(to history: BlackHistoryModel) {
        var updatedHistory = history
        updatedHistory.salvationCount += 1
        
        do {
            try storageService.updateBlackHistory(updatedHistory)
            
            var user = storageService.loadUser()
            user.salvationGiven += 1
            user.addPoints(PointsConstants.giveSalvation)
            try storageService.saveUser(user)
            
            if let index = blackHistories.firstIndex(where: { $0.id == history.id }) {
                blackHistories[index] = updatedHistory
                applyFiltersAndSort()
            }
            
            AudioService.shared.playMokugyo()
            
        } catch {
            print("Failed to save salvation: \(error)")
        }
    }
    
    func toggleCategory(_ category: Category) {
        if selectedCategory == category {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
    }
    
    #if DEBUG
    func loadMockData() {
        storageService.loadMockData()
        loadBlackHistories()
    }
    #endif
}