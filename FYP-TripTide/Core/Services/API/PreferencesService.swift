import Foundation

class PreferencesService {
    static let shared = PreferencesService()
    
    private let cache = NSCache<NSString, NSArray>()
    private let cacheKey = "preferences" as NSString
    private let cacheDuration: TimeInterval = 300 // 5 minutes
    private var lastFetchTime: Date?
    
    private init() {}
    
    func fetchPreferences() async throws -> [String] {
        // Check if cache is still valid
        if let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheDuration,
           let cachedPrefs = cache.object(forKey: cacheKey) as? [String] {
            return cachedPrefs
        }
        
        // If cache is invalid or missing, fetch from server
        let url = URL(string: "\(APIConfig.baseURL)/preferences")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(await AuthManager.shared.token ?? "")", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(PreferencesResponse.self, from: data)
        
        // Update cache
        cache.setObject(response.preferredTags as NSArray, forKey: cacheKey)
        lastFetchTime = Date()
        
        return response.preferredTags
    }
    
    func updatePreferences(tags: Set<Tag>) async throws {
        let url = URL(string: "\(APIConfig.baseURL)/preferences")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(await AuthManager.shared.token ?? "")", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let tagNames = Array(tags).map { $0.name }
        let body = PreferencesRequest(preferredTags: tagNames)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, _) = try await URLSession.shared.data(for: request)
        
        // Update cache after successful update
        cache.setObject(tagNames as NSArray, forKey: cacheKey)
        lastFetchTime = Date()
    }
    
    func clearCache() {
        cache.removeObject(forKey: cacheKey)
        lastFetchTime = nil
    }
}

private struct PreferencesResponse: Codable {
    let preferredTags: [String]
}

private struct PreferencesRequest: Codable {
    let preferredTags: [String]
} 