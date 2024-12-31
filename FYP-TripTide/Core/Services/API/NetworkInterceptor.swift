import Foundation

class NetworkInterceptor: NSObject, URLSessionDelegate {
    static let shared = NetworkInterceptor()
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    func addAuthorizationHeader(to request: inout URLRequest) async {
        // Access token on main actor
        if let token = await AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    
    func handleResponse(_ response: HTTPURLResponse, for request: URLRequest) async throws {
        if response.statusCode == 401 {
            do {
                // Try to refresh the token
                _ = try await AuthService.shared.refreshToken()
                
                // Retry the original request with the new token
                var newRequest = request
                await addAuthorizationHeader(to: &newRequest)
                let (_, newResponse) = try await URLSession.shared.data(for: newRequest)
                
                if let httpResponse = newResponse as? HTTPURLResponse, 
                   httpResponse.statusCode == 401 {
                    // If still unauthorized after refresh, sign out
                    await AuthManager.shared.signOut()
                    throw AuthError.invalidCredentials
                }
            } catch {
                // If refresh fails, sign out
                await AuthManager.shared.signOut()
                throw error
            }
        }
    }
} 