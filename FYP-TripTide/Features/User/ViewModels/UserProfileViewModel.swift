import Foundation

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var preferences: [String] = []
    
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
    
    @MainActor
    func fetchPreferences() async {
        do {
            let preferences = try await PreferencesService.shared.fetchPreferences()
            self.preferences = preferences
        } catch {
            print("Error fetching preferences: \(error)")
        }
    }
    
    @MainActor
    func updatePreferences(tags: Set<Tag>) async {
        do {
            try await PreferencesService.shared.updatePreferences(tags: tags)
        } catch {
            print("Error updating preferences: \(error)")
        }
    }
}
