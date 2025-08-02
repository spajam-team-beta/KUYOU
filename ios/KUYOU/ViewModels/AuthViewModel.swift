import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var passwordConfirmation = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isShowingRegistration = false
    
    private var cancellables = Set<AnyCancellable>()
    private let authService = AuthService.shared
    
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var isValidPassword: Bool {
        return password.count >= 6
    }
    
    var isValidPasswordConfirmation: Bool {
        return password == passwordConfirmation && !password.isEmpty
    }
    
    var canLogin: Bool {
        return isValidEmail && isValidPassword && !isLoading
    }
    
    var canRegister: Bool {
        return isValidEmail && isValidPassword && isValidPasswordConfirmation && !isLoading
    }
    
    func login() {
        guard canLogin else { return }
        
        isLoading = true
        errorMessage = nil
        
        authService.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in
                    // Navigation will be handled by the app state
                }
            )
            .store(in: &cancellables)
    }
    
    func register() {
        guard canRegister else { return }
        
        isLoading = true
        errorMessage = nil
        
        authService.register(
            email: email,
            password: password,
            passwordConfirmation: passwordConfirmation
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { _ in
                // Navigation will be handled by the app state
            }
        )
        .store(in: &cancellables)
    }
    
    func toggleAuthMode() {
        isShowingRegistration.toggle()
        errorMessage = nil
        passwordConfirmation = ""
    }
}