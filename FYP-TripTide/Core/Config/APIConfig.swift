import Foundation

enum APIConfig {
    #if DEBUG
    static let baseURL = "http://localhost:8080/api"  // Development server
    #elseif STAGING
    static let baseURL = "https://triptide-backend-staging-33911108688.asia-east2.run.app/api"  // Staging server
    #else
    static let baseURL = "https://triptide-backend-33911108688.asia-east2.run.app/api"  // Production server
    #endif
} 