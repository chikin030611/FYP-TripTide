import SwiftUI

struct UserTabView: View {
    @State private var showLoginSheet = false
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        NavigationView {
            if authManager.isAuthenticated {
                UserProfileView()
            } else {
                LoginView()
            }
        }
    }
}
