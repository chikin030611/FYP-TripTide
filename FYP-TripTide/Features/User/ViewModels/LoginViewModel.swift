import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: Error?
    
    func login() async {
        isLoading = true
        error = nil
        
        do {
            let response = try await AuthService.shared.login(
                email: email,
                password: password
            )
            if response.success {
                // Handle successful login
                AuthManager.shared.token = response.token
                AuthManager.shared.refreshToken = response.refreshToken
            } else {
                throw AuthError.serverError(response.message ?? "Login failed")
            }
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
} 