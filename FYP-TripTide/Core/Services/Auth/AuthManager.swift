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
        // Check if token exists on initialization
        isAuthenticated = token != nil
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
} 