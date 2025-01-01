import SwiftUI

struct UserTabView: View {
    @State private var showLoginSheet = false
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        NavigationView {
            if authManager.isAuthenticated {
                LoggedInView()
            } else {
                LoginView()
            }
        }
    }
}

// Simple view for logged in state
private struct LoggedInView: View {
    @State private var showingLogoutAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("User is logged in")
                .font(.headline)
            
            Button(role: .destructive, action: { showingLogoutAlert = true }) {
                Text("Sign Out")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                AuthManager.shared.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

#Preview {
    UserTabView()
}