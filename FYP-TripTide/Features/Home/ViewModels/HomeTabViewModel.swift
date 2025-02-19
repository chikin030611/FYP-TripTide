import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isUserLoggedIn = false
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?
    
    
    // func setup() async {
    //     await checkUserLoginStatus()
    //     if isUserLoggedIn {
    //         await fetchUserProfile()
    //     }
    // }
    
    // func checkUserLoginStatus() async {
    //     await AuthManager.shared.validateToken()
    //     isUserLoggedIn = AuthManager.shared.isAuthenticated
    // }
    
    // func fetchUserProfile() async {
    //     isLoading = true
    //     error = nil
        
    //     do {
    //         user = try await AuthService.shared.getUserProfile()
    //     } catch {
    //         self.error = error
    //     }
    //     isLoading = false
    // }
}