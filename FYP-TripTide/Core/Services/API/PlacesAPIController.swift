import Foundation

class PlacesAPIController {
    static let shared = PlacesAPIController()
    
    func fetchPlaces(type: String, limit: Int) async throws -> [PlaceBasicData] {
        guard let url = URL(string: "\(APIConfig.baseURL)/places?type=\(type)&limit=\(limit)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([PlaceBasicData].self, from: data)
    }
    
    func fetchPlaceDetail(id: String) async throws -> PlaceDetailResponse {
        guard let url = URL(string: "\(APIConfig.baseURL)/places/\(id)/details") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(PlaceDetailResponse.self, from: data)
    }
    
    func appendAPIKey(to photoUrl: String) -> String {
        // Check if URL already has parameters
        if photoUrl.contains("?") {
            return "\(photoUrl)\(APIConfig.googleMapsAPIKey)"
        } else {
            return "\(photoUrl)\(APIConfig.googleMapsAPIKey)"
        }
    }
    
    func searchPlaces(name: String, page: Int) async throws -> [PlaceBasicData] {
        let baseURL = "\(APIConfig.baseURL)/places/search"
        let queryItems = [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        var urlComps = URLComponents(string: baseURL)!
        urlComps.queryItems = queryItems
        
        let request = URLRequest(url: urlComps.url!)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidURL
        }
        
        return try JSONDecoder().decode([PlaceBasicData].self, from: data)
    }
}

struct PlaceBasicData: Codable {
    let placeId: String
    let name: String
    let tags: [String]
    let photoUrl: String
    let rating: Double
}

enum APIError: Error {
    case invalidURL
    case decodingError
    case networkError
} 