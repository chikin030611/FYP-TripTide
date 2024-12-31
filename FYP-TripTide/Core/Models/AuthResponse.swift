struct AuthResponse: Codable {
    let success: Bool
    let token: String?
    let type: String?
    let message: String?
    let errors: [String: String]?
} 