import Foundation

struct APIRequest<T: Codable> {
    let endpoint: String
    let method: HTTPMethod
    let body: Data?
    let requiresAuth: Bool
    
    init(endpoint: String, 
         method: HTTPMethod = .get, 
         body: Encodable? = nil, 
         requiresAuth: Bool = false) throws {
        self.endpoint = endpoint
        self.method = method
        self.body = try body.map { try JSONEncoder().encode($0) }
        self.requiresAuth = requiresAuth
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
} 

enum APIError: Error {
    case invalidURL
    case decodingError
    case networkError
    case unauthorized
    case invalidResponse
    case serverError(statusCode: Int)
    case serverErrorWithMessage(statusCode: Int, message: String)
    case placeAlreadyInTrip
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        case .serverErrorWithMessage(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
        case .decodingError:
            return "Decoding error"
        case .networkError:
            return "Network error"
        case .placeAlreadyInTrip:
            return "This place is already in your trip"
        }
    }
}