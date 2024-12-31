import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError
    case invalidResponse
    case serverError(String)
    case validationError([String: String])
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Network error occurred"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let message):
            return message
        case .validationError(let errors):
            return errors.values.joined(separator: "\n")
        }
    }
}

@MainActor
class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(APIConfig.baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = LoginRequest(email: email, password: password)
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        switch httpResponse.statusCode {
        case 200:
            if let token = authResponse.token {
                AuthManager.shared.token = token
                return authResponse
            } else {
                throw AuthError.invalidResponse
            }
        case 401:
            throw AuthError.invalidCredentials
        case 400:
            if let errors = authResponse.errors {
                throw AuthError.validationError(errors)
            } else {
                throw AuthError.serverError(authResponse.message ?? "Bad request")
            }
        default:
            throw AuthError.serverError(authResponse.message ?? "Server error")
        }
    }
    
    func register(username: String, email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(APIConfig.baseURL)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = RegistrationRequest(username: username, email: email, password: password)
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        switch httpResponse.statusCode {
        case 200:
            return authResponse
        case 400:
            if let errors = authResponse.errors {
                throw AuthError.validationError(errors)
            } else {
                throw AuthError.serverError(authResponse.message ?? "Registration failed")
            }
        default:
            throw AuthError.serverError(authResponse.message ?? "Server error")
        }
    }
    
    func refreshToken() async throws -> AuthResponse {
        let url = URL(string: "\(APIConfig.baseURL)/auth/refresh")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        switch httpResponse.statusCode {
        case 200:
            if let token = authResponse.token {
                AuthManager.shared.token = token
                return authResponse
            } else {
                throw AuthError.invalidResponse
            }
        default:
            throw AuthError.serverError(authResponse.message ?? "Failed to refresh token")
        }
    }
}

// Request models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegistrationRequest: Codable {
    let username: String
    let email: String
    let password: String
} 