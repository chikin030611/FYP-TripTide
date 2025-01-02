import Foundation

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?
    
    func fetchUserProfile() {
        isLoading = true
        error = nil
        
        Task {
            do {
                user = try await AuthService.shared.getUserProfile()
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}