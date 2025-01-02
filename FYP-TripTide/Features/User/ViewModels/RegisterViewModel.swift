import Foundation

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showSuccessAlert = false
    
    func register() async {
        isLoading = true
        error = nil
        
        do {
            let response = try await AuthService.shared.register(
                username: username,
                email: email,
                password: password
            )
            guard response.success else {
                throw AuthError.serverError(response.message ?? "Registration failed")
            }
            showSuccessAlert = true
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    var isFormValid: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty
    }
} 