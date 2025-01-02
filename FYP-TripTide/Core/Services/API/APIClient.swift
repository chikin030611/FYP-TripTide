import Foundation

class APIClient {
    static let shared = APIClient()
    
    private init() {}
    
    func perform<T: Codable>(_ request: APIRequest<T>) async throws -> T {
        var urlRequest = URLRequest(url: URL(string: "\(APIConfig.baseURL)\(request.endpoint)")!)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if request.requiresAuth {
            guard let token = await AuthManager.shared.token else {
                throw AuthError.invalidCredentials
            }
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = request.body {
            urlRequest.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AuthError.serverError("Server returned status code \(httpResponse.statusCode)")
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
} 