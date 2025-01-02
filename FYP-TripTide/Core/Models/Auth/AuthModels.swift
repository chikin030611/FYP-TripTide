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