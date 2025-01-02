import SwiftUI

struct UserTabView: View {
    @State private var showLoginSheet = false
    @StateObject private var authManager = AuthManager.shared
    @State private var isCheckingAuth = true
    
    var body: some View {
        NavigationView {
            Group {
                if isCheckingAuth {
                    ProgressView() // Show loading while checking auth
                } else if authManager.isAuthenticated {
                    UserProfileView()
                } else {
                    LoginView()
                }
            }
        }
        .task {
            // Validate token when view appears
            await authManager.validateToken()
            isCheckingAuth = false
        }
    }
}
