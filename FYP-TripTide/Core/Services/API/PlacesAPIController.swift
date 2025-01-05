import Foundation

class PlacesAPIController {
    static let shared = PlacesAPIController()
    
    func fetchPlaces(type: String, limit: Int) async throws -> [PlaceBasicData
] {
        guard let url = URL(string: "\(APIConfig.baseURL)/places?type=\(type)&limit=\(limit)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([PlaceBasicData
    ].self, from: data)
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