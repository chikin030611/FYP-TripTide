import Foundation

enum APIConfig {
    #if DEBUG
    static let baseURL = "http://localhost:8080/api"  // Development server
    #else
    static let baseURL = "https://your-production-server.com/api"  // Production server
    #endif
} 