import Foundation

class APIClient {
    static let shared = APIClient()
    private let baseURL = APIConfig.baseURL
    
    private init() {}
    
    func request<T: Decodable>(_ endpoint: String, method: String = "GET", body: Encodable? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header
        await NetworkInterceptor.shared.addAuthorizationHeader(to: &request)
        
        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            try await NetworkInterceptor.shared.handleResponse(httpResponse, for: request)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
} 