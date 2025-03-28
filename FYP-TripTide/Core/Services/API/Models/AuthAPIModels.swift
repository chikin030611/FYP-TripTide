import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegistrationRequest: Codable {
    let username: String
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let success: Bool
    let token: String?
    let refreshToken: String?
    let type: String?
    let message: String?
    let errors: [String: String]?
    
    // For token validation
    let valid: Bool?
    let remainingTime: Int?
} 

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