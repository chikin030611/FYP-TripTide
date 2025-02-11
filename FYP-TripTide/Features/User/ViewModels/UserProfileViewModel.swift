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
            let url = URL(string: "\(APIConfig.baseURL)/preferences")!
            var request = URLRequest(url: url)
            request.addValue("Bearer \(AuthManager.shared.token ?? "")", forHTTPHeaderField: "Authorization")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(PreferencesResponse.self, from: data)
            self.preferences = response.preferredTags
        } catch {
            print("Error fetching preferences: \(error)")
        }
    }
    
    @MainActor
    func updatePreferences(tags: Set<Tag>) async {
        do {
            let url = URL(string: "\(APIConfig.baseURL)/preferences")!
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("Bearer \(AuthManager.shared.token ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let tagNames = Array(tags).map { $0.name }
            let body = PreferencesRequest(preferredTags: tagNames)
            request.httpBody = try JSONEncoder().encode(body)
            
            let (_, _) = try await URLSession.shared.data(for: request)
            self.preferences = tagNames
        } catch {
            print("Error updating preferences: \(error)")
        }
    }
}

struct PreferencesResponse: Codable {
    let preferredTags: [String]
}

struct PreferencesRequest: Codable {
    let preferredTags: [String]
}