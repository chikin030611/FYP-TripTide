import Foundation
import KeychainSwift

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    private let keychain = KeychainSwift()
    
    private let tokenKey = "auth_token"
    private let refreshTokenKey = "refresh_token"
    
    @Published private(set) var isAuthenticated = false
    
    private init() {
        // Check if token exists and validate it
        Task {
            await validateToken()
        }
    }
    
    var token: String? {
        get { keychain.get(tokenKey) }
        set {
            if let token = newValue {
                keychain.set(token, forKey: tokenKey)
                isAuthenticated = true
            } else {
                keychain.delete(tokenKey)
                isAuthenticated = false
            }
        }
    }
    
    var refreshToken: String? {
        get { keychain.get(refreshTokenKey) }
        set {
            if let token = newValue {
                keychain.set(token, forKey: refreshTokenKey)
            } else {
                keychain.delete(refreshTokenKey)
            }
        }
    }
    
    func signOut() {
        token = nil
        refreshToken = nil
    }
    
    func validateToken() async {
        guard let token = token else {
            isAuthenticated = false
            return
        }
        
        do {
            let response = try await AuthService.shared.validateToken(token: token)
            isAuthenticated = response.valid ?? false
            
            // If token is about to expire (e.g., less than 5 minutes remaining)
            if let remainingTime = response.remainingTime,
               remainingTime < 300000 { // 5 minutes in milliseconds
                try await refreshTokenIfNeeded()
            }
        } catch {
            isAuthenticated = false
        }
    }
    
    private func refreshTokenIfNeeded() async throws {
        guard let refreshToken = refreshToken else { return }
        do {
            let response = try await AuthService.shared.refreshToken(refreshToken: refreshToken)
            if let newToken = response.token {
                self.token = newToken
            }
        } catch {
            signOut()
            throw error
        }
    }
} 