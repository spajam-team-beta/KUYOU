import Foundation
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private let keychain = KeychainHelper()
    private let tokenKey = "jwt_token"
    private let userKey = "current_user"
    
    private var cancellables = Set<AnyCancellable>()
    
    var currentToken: String? {
        return keychain.get(tokenKey)
    }
    
    private init() {
        loadStoredCredentials()
    }
    
    private func loadStoredCredentials() {
        if keychain.get(tokenKey) != nil,
           let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    func login(email: String, password: String) -> AnyPublisher<User, APIError> {
        let loginRequest = LoginRequest(
            user: LoginRequest.LoginData(
                email: email,
                password: password
            )
        )
        
        guard let body = try? APIService.shared.encode(loginRequest) else {
            return Fail(error: APIError.decodingError)
                .eraseToAnyPublisher()
        }
        
        return APIService.shared.request(
            path: "/auth/login",
            method: "POST",
            body: body,
            authenticated: false,
            responseType: AuthResponse.self
        )
        .map { [weak self] response in
            let user = response.user.data.attributes
            self?.saveCredentials(user: user, token: response.token)
            return user
        }
        .eraseToAnyPublisher()
    }
    
    func register(email: String, password: String, passwordConfirmation: String) -> AnyPublisher<User, APIError> {
        print("🔍 AuthService register called with email: \(maskEmail(email))")
        
        let registerRequest = RegisterRequest(
            user: RegisterRequest.RegisterData(
                email: email,
                password: password,
                passwordConfirmation: passwordConfirmation
            )
        )
        
        print("🔍 RegisterRequest created for email: \(email)")
        
        guard let body = try? APIService.shared.encode(registerRequest) else {
            print("❌ Failed to encode RegisterRequest")
            return Fail(error: APIError.decodingError)
                .eraseToAnyPublisher()
        }
        
        print("🔍 Request body encoded successfully")
        
        print("🔍 About to call APIService.request for /auth/register")
        
        return APIService.shared.request(
            path: "/auth/register",
            method: "POST",
            body: body,
            authenticated: false,
            responseType: AuthResponse.self
        )
        .handleEvents(
            receiveOutput: { response in
                print("🔍 AuthService register response: \(response)")
                print("🔍 User data: \(response.user)")
                print("🔍 Token: \(response.token)")
            },
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("❌ AuthService register error: \(error)")
                }
            }
        )
        .map { [weak self] response in
            print("🔍 Extracting user attributes...")
            let user = response.user.data.attributes
            print("🔍 Extracted user: \(user)")
            self?.saveCredentials(user: user, token: response.token)
            return user
        }
        .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, APIError> {
        return APIService.shared.request(
            path: "/auth/logout",
            method: "DELETE",
            responseType: [String: String].self
        )
        .map { [weak self] _ in
            self?.clearCredentials()
            return ()
        }
        .eraseToAnyPublisher()
    }
    
    private func saveCredentials(user: User, token: String) {
        currentUser = user
        isAuthenticated = true
        
        keychain.save(token, forKey: tokenKey)
        
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userKey)
        }
    }
    
    private func clearCredentials() {
        currentUser = nil
        isAuthenticated = false
        
        keychain.delete(tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
    }
    
    func updateCurrentUser(_ user: User) {
        currentUser = user
        // ユーザー情報をUserDefaultsに保存
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userKey)
        }
    }
}