// import Foundation

// class PreferencesService {
//     static let shared = PreferencesService()
    
//     private init() {}
    
//     func fetchPreferences() async throws -> [String] {
//         let url = URL(string: "\(APIConfig.baseURL)/preferences")!
//         var request = URLRequest(url: url)
//         request.addValue("Bearer \(await AuthManager.shared.token ?? "")", forHTTPHeaderField: "Authorization")
        
//         let (data, _) = try await URLSession.shared.data(for: request)
//         let response = try JSONDecoder().decode(PreferencesResponse.self, from: data)
//         return response.preferredTags
//     }
    
//     func updatePreferences(tags: Set<Tag>) async throws {
//         let url = URL(string: "\(APIConfig.baseURL)/preferences")!
//         var request = URLRequest(url: url)
//         request.httpMethod = "PUT"
//         request.addValue("Bearer \(await AuthManager.shared.token ?? "")", forHTTPHeaderField: "Authorization")
//         request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
//         let tagNames = Array(tags).map { $0.name }
//         let body = PreferencesRequest(preferredTags: tagNames)
//         request.httpBody = try JSONEncoder().encode(body)
        
//         let (_, _) = try await URLSession.shared.data(for: request)
//     }
// }

// private struct PreferencesResponse: Codable {
//     let preferredTags: [String]
// }

// private struct PreferencesRequest: Codable {
//     let preferredTags: [String]
// } 