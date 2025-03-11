import Foundation
import KeychainSwift
import JWTDecode

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    private let keychain: KeychainSwift
    
    private let tokenKey = "auth_token"
    private let refreshTokenKey = "refresh_token"
    
    @Published private(set) var isAuthenticated = false
    
    private init() {
        keychain = KeychainSwift()
        keychain.synchronizable = true  // Enable keychain sharing between launches
        
        // Check if token exists and validate it
        Task {
            await validateToken()
        }
    }
    
    var token: String? {
        get {
            let savedToken = keychain.get(tokenKey)
            return savedToken
        }
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
        get {
            let savedRefreshToken = keychain.get(refreshTokenKey)
            return savedRefreshToken
        }
        set {
            if let token = newValue {
                keychain.set(token, forKey: refreshTokenKey)
            } else {
                keychain.delete(refreshTokenKey)
            }
        }
    }
    
    func signOut() async {
        // Clear existing auth data
        self.token = nil
        self.refreshToken = nil
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        
        // Clear all caches
        PreferencesService.shared.clearCache()
        PlacesService.shared.clearCache()
        await TripsManager.shared.refreshAllData()
    }
    
    func validateToken() async {
        guard let token = token else {
            isAuthenticated = false
            return
        }
        
        do {
            let response = try await AuthService.shared.validateToken(token: token)
            
            // Check if token is expired
            if let exp = getTokenExpiration(from: token) {
                let isExpired = exp < Date()
                if isExpired {
                    try await refreshTokenIfNeeded()
                    return
                }
            }
            
            isAuthenticated = response.valid ?? false
            
        } catch {
            do {
                try await refreshTokenIfNeeded()
            } catch {
                isAuthenticated = false
            }
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
            await signOut()
            throw error
        }
    }
    
    private func getTokenExpiration(from token: String) -> Date? {
        let segments = token.components(separatedBy: ".")
        guard segments.count > 1,
              let payload = segments[1].base64Decoded(),
              let json = try? JSONSerialization.jsonObject(with: payload, options: []) as? [String: Any],
              let expiration = json["exp"] as? TimeInterval
        else { return nil }
        
        return Date(timeIntervalSince1970: expiration)
    }
}

private extension String {
        func base64Decoded() -> Data? {
            var base64 = self
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            if base64.count % 4 != 0 {
                base64.append(String(repeating: "=", count: 4 - base64.count % 4))
            }
            return Data(base64Encoded: base64)
        }
    }