import Foundation
import Combine

struct UserStats: Codable {
    let totalPosts: Int
    let activePosts: Int
    let resolvedPosts: Int
    let totalReplies: Int
    let bestReplies: Int
    let totalSympathiesGiven: Int
    let totalSympathiesReceived: Int
    
    enum CodingKeys: String, CodingKey {
        case totalPosts = "total_posts"
        case activePosts = "active_posts"
        case resolvedPosts = "resolved_posts"
        case totalReplies = "total_replies"
        case bestReplies = "best_replies"
        case totalSympathiesGiven = "total_sympathies_given"
        case totalSympathiesReceived = "total_sympathies_received"
    }
}

struct ProfileResponse: Codable {
    let profile: ProfileData
    
    struct ProfileData: Codable {
        let user: User
        let stats: UserStats
    }
}

class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var userStats: UserStats?
    @Published var myPosts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let authService = AuthService.shared
    
    init() {
        currentUser = authService.currentUser
    }
    
    func loadProfile() {
        print("🔄 ProfileViewModel: プロフィール読み込み開始")
        isLoading = true
        errorMessage = nil
        
        APIService.shared.request(
            path: "/profile",
            method: "GET",
            responseType: ProfileResponse.self
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
                print("📨 ProfileViewModel: プロフィールデータ受信")
                print("📝 受信したユーザー: \(response.profile.user.displayNickname)")
                self?.currentUser = response.profile.user
                self?.userStats = response.profile.stats
                // AuthServiceも更新
                self?.authService.updateCurrentUser(response.profile.user)
                print("✅ ProfileViewModel: プロフィール更新完了")
                self?.loadMyPosts()
            }
        )
        .store(in: &cancellables)
    }
    
    func loadMyPosts() {
        APIService.shared.request(
            path: "/posts?filter=mine",
            method: "GET",
            responseType: PostsResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to load my posts: \(error)")
                }
            },
            receiveValue: { [weak self] response in
                self?.myPosts = response.posts
            }
        )
        .store(in: &cancellables)
    }
    
    func logout() {
        authService.logout()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Logout error: \(error)")
                    }
                },
                receiveValue: { _ in
                    // Navigation will be handled by the app state
                }
            )
            .store(in: &cancellables)
    }
    
    func updateUserNickname(_ nickname: String) {
        print("🔄 ProfileViewModel: ニックネーム更新開始 '\(nickname)'")
        if let user = currentUser {
            print("📝 現在のユーザー: \(user.displayNickname)")
            // Update local user object immediately
            let updatedUser = User(
                id: user.id,
                email: user.email,
                nickname: nickname.isEmpty ? nil : nickname,
                totalPoints: user.totalPoints,
                createdAt: user.createdAt
            )
            print("📝 更新後のユーザー: \(updatedUser.displayNickname)")
            self.currentUser = updatedUser
            
            // Update auth service
            authService.updateCurrentUser(updatedUser)
            print("✅ ProfileViewModel: ローカル更新完了")
        } else {
            print("❌ ProfileViewModel: currentUserがnil")
        }
    }
}