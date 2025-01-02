import SwiftUI

struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var showingLogoutAlert = false
    @StateObject var themeManager = ThemeManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(themeManager.selectedTheme.primaryColor)
                    
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let user = viewModel.user {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(user.username)
                                .font(themeManager.selectedTheme.titleFont)
                                .foregroundColor(themeManager.selectedTheme.primaryColor)
                            
                            Text(user.email)
                                .font(themeManager.selectedTheme.bodyTextFont)
                                .foregroundColor(themeManager.selectedTheme.secondaryColor)
                        }
                    } else if let error = viewModel.error {
                        Text(error.localizedDescription)
                            .foregroundColor(themeManager.selectedTheme.warningColor)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                Button(role: .destructive, action: { showingLogoutAlert = true }) {
                    Text("Sign Out")
                }
                .padding(.horizontal)
                .buttonStyle(TertiaryButtonStyle())
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
}