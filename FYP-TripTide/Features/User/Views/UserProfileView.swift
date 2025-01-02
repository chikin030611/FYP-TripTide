import SwiftUI

struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var showingLogoutAlert = false
    @StateObject var themeManager = ThemeManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            if viewModel.isLoading {
                ProgressView()
            } else if let user = viewModel.user {
                VStack(spacing: 12) {
                    Text(user.username)
                        .font(themeManager.selectedTheme.titleFont)
                    
                    Text(user.email)
                        .font(themeManager.selectedTheme.bodyTextFont)
                        .foregroundColor(.gray)
                }
            } else if let error = viewModel.error {
                Text(error.localizedDescription)
                    .foregroundColor(themeManager.selectedTheme.warningColor)
                    .multilineTextAlignment(.center)
            }
            
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
        .padding()
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                AuthManager.shared.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .onAppear {
            viewModel.fetchUserProfile()
        }
    }
}
