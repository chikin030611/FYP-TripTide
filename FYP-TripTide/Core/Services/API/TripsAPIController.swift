import Foundation

class TripsAPIController {
    private let baseURL = APIConfig.baseURL
    
    static let shared = TripsAPIController()
    private init() {}
    
    func fetchTrips() async throws -> [Trip] {
        guard let url = URL(string: "\(baseURL)/trips") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = await AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.unauthorized
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        
        let tripResponses = try decoder.decode([TripResponse].self, from: data)
        return tripResponses.map { $0.toTrip() }
    }
}
