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
} 