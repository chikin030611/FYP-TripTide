import SwiftUI

struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @StateObject private var filterViewModel = FilterViewModel()
    @State private var showingLogoutAlert = false
    @State private var showingFilterSheet = false
    @StateObject var themeManager = ThemeManager()
    @State private var hasLoadedInitialData = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileSection
                
                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    interestRow()
                }
                .padding(.horizontal)
                
                Divider()

                Spacer()
                
                Button(role: .destructive, action: { showingLogoutAlert = true }) {
                    Text("Sign Out")
                }
                .padding(.horizontal)
                .buttonStyle(TertiaryButtonStyle())
            }
            .padding()
            .sheet(isPresented: $showingFilterSheet) {
                FilterSheet(viewModel: filterViewModel)
                    .onDisappear {
                        // Update preferences when sheet is dismissed
                        Task {
                            await viewModel.updatePreferences(tags: filterViewModel.selectedTags)
                        }
                    }
            }
            .alert("Sign Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        await AuthManager.shared.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .task {
                guard !hasLoadedInitialData else { return }
                
                // Load data only once when view first appears
                await viewModel.fetchUserProfile()
                await filterViewModel.loadTags()
                await viewModel.fetchPreferences()
                
                // Set initial selected tags from preferences
                let prefTags = viewModel.preferences.map { Tag(name: $0) }
                filterViewModel.selectedTags = Set(prefTags)
                
                hasLoadedInitialData = true
            }
        }
    }
}

extension UserProfileView {
    private var profileSection: some View {
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
        
    }
}

extension UserProfileView {
    private func interestRow() -> some View {
        Button{
            showingFilterSheet = true
        } label: {
            HStack(alignment: .center, spacing: 20) {
                Image(systemName: "heart")
                    .font(.system(size: 25))
                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                
                Text("Interests")
                    .font(themeManager.selectedTheme.boldBodyTextFont)
                    .foregroundColor(themeManager.selectedTheme.primaryColor)

                Spacer()

                if !filterViewModel.selectedTags.isEmpty {
                    Button {
                        showingFilterSheet = true
                    } label: {
                        Text("\(filterViewModel.selectedTags.count) Interests")
                    }
                    .buttonStyle(SecondaryTagButtonStyle())
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 15))
                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
            }
        }
    }

    private func row(imageName: String, title: String, function: @escaping () -> Void) -> some View {
        Button(action: function) {
            HStack(alignment: .center, spacing: 20) {
                Image(systemName: imageName)
                    .font(.system(size: 25))
                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                
                Text(title)
                    .font(themeManager.selectedTheme.boldBodyTextFont)
                    .foregroundColor(themeManager.selectedTheme.primaryColor)

                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 15))
                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
            }
        }
    }
}