import Foundation

@MainActor
class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    // Add generic perform method to handle API requests
    private func perform<T: Codable>(_ endpoint: String, method: String = "GET", requiresAuth: Bool = false, body: Data? = nil) async throws -> T {
        var urlRequest = URLRequest(url: URL(string: "\(APIConfig.baseURL)\(endpoint)")!)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            guard let token = await AuthManager.shared.token else {
                throw AuthError.invalidCredentials
            }
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
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
    
    // Update getUserProfile to use the new perform method
    func getUserProfile() async throws -> User {
        return try await perform("/users/profile", method: "GET", requiresAuth: true)
    }
    
    // Update validateToken to use the new perform method
    func validateToken(token: String) async throws -> AuthResponse {
        var urlRequest = URLRequest(url: URL(string: "\(APIConfig.baseURL)/auth/validate")!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await perform("/auth/validate", method: "GET", requiresAuth: true)
    }
    
    // Update refreshToken to use the new perform method
    func refreshToken(refreshToken: String) async throws -> AuthResponse {
        var urlRequest = URLRequest(url: URL(string: "\(APIConfig.baseURL)/auth/refresh")!)
        urlRequest.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
        
        return try await perform("/auth/refresh", method: "POST", requiresAuth: true)
    }
    
    // Update login to use the new perform method
    func login(email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(email: email, password: password)
        let encodedBody = try? JSONEncoder().encode(body)
        
        return try await perform("/auth/login", method: "POST", requiresAuth: false, body: encodedBody)
    }
    
    // Update register to use the new perform method
    func register(username: String, email: String, password: String) async throws -> AuthResponse {
        let body = RegistrationRequest(username: username, email: email, password: password)
        let encodedBody = try? JSONEncoder().encode(body)
        
        return try await perform("/auth/register", method: "POST", requiresAuth: false, body: encodedBody)
    }
}