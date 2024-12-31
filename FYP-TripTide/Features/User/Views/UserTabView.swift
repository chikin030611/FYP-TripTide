import SwiftUI

struct UserTabView: View {
    @State private var showLoginSheet = false
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        NavigationView {
            Group {
                if authManager.isAuthenticated {
                    LoggedInView()
                } else {
                    NotLoggedInView(showLoginSheet: $showLoginSheet)
                }
            }
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
        }
    }
}

// View shown when user is not logged in
private struct NotLoggedInView: View {
    @Binding var showLoginSheet: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Sign in to view your profile")
                .font(.headline)
            
            Button(action: { showLoginSheet = true }) {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
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