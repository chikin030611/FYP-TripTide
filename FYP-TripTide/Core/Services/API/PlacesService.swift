import Foundation

class PlacesService {
    static let shared = PlacesService()
    
    private let tagsCache = NSCache<NSString, NSArray>()
    private let tagsCacheKey = "tags" as NSString
    private let tagsCacheDuration: TimeInterval = 300 // 5 minutes
    private var lastTagsFetchTime: [String: Date] = [:]
    
    func fetchPlacesByType(type: String, limit: Int) async throws -> [PlaceBasicData] {
        guard let url = URL(string: "\(APIConfig.baseURL)/places?type=\(type)&limit=\(limit)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([PlaceBasicData].self, from: data)
    }

    func fetchPlaceBasicById(id: String) async throws -> PlaceBasicData {
        // Check cache first
        if let cached = await PlaceBasicCache.shared.get(id) {
            return cached
        }
        
        guard let url = URL(string: "\(APIConfig.baseURL)/places/\(id)/basic") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let place = try JSONDecoder().decode(PlaceBasicData.self, from: data)
        
        // Store in cache
        await PlaceBasicCache.shared.set(place, for: id)
        
        return place
    }

    func fetchPlaceDetailById(id: String) async throws -> PlaceDetailResponse {
        // Check cache first
        if let cached = await PlaceCache.shared.get(id) {
            return cached
        }
        
        guard let url = URL(string: "\(APIConfig.baseURL)/places/\(id)/details") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(PlaceDetailResponse.self, from: data)
        
        // Store in cache
        await PlaceCache.shared.set(response, for: id)
        
        return response
    }
    
    func appendAPIKey(to photoUrl: String) -> String {
        // Check if URL already has parameters
        if photoUrl.contains("?") {
            return "\(photoUrl)\(APIConfig.googleMapsAPIKey)"
        } else {
            return "\(photoUrl)\(APIConfig.googleMapsAPIKey)"
        }
    }
    
    func searchPlaces(name: String, tags: [String], page: Int) async throws -> [PlaceBasicData] {
        let baseURL = "\(APIConfig.baseURL)/places/search"
        var queryItems = [
            URLQueryItem(name: "page", value: String(page))
        ]
        
        queryItems.append(URLQueryItem(name: "name", value: name.isEmpty ? " " : name))
        
        if !tags.isEmpty {
            queryItems.append(URLQueryItem(name: "tags", value: tags.joined(separator: ",")))
        }
        
        var urlComps = URLComponents(string: baseURL)!
        urlComps.queryItems = queryItems
        
        let request = URLRequest(url: urlComps.url!)

        print("Fetching places with URL: \(urlComps.url!)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidURL
        }
        
        return try JSONDecoder().decode([PlaceBasicData].self, from: data)
    }
    
    func fetchTags(type: String) async throws -> [Tag] {
        // Check cache first with proper type casting
        let cacheKey = "\(type)_tags" as NSString
        if let lastFetch = lastTagsFetchTime[type],
           Date().timeIntervalSince(lastFetch) < tagsCacheDuration,
           let cachedTags = tagsCache.object(forKey: cacheKey),
           let tags = cachedTags as? [Tag] {  // Safe casting
            return tags
        }
        
        guard let url = URL(string: "\(APIConfig.baseURL)/places/tags?type=\(type)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let tags = try JSONDecoder().decode([Tag].self, from: data)
        
        // Update cache with proper type conversion
        tagsCache.setObject(NSArray(array: tags), forKey: cacheKey)
        lastTagsFetchTime[type] = Date()
        
        return tags
    }
    
    func clearCache() {
        tagsCache.removeAllObjects()
        lastTagsFetchTime.removeAll()
        Task {
            await PlaceBasicCache.shared.clear()
            await PlaceCache.shared.clear() // assuming this method exists
        }
    }
    
    func fetchRecommendations() async throws -> [PlaceBasicData] {
        guard let url = URL(string: "\(APIConfig.baseURL)/recommendations") else {
            throw APIError.invalidURL
        }
        
        // Create request with authorization header
        var request = URLRequest(url: url)
        if let token = await AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.unauthorized
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for unauthorized response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        // Decode the array directly
        return try JSONDecoder().decode([PlaceBasicData].self, from: data)
    }
    
    func fetchPlaceOpeningHours(id: String) async throws -> PlaceDetailResponse.OpeningHours {
        guard let url = URL(string: "\(APIConfig.baseURL)/places/\(id)/opening-hours") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(PlaceDetailResponse.OpeningHours.self, from: data)
    }
}
