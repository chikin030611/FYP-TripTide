import Foundation

enum APIConfig {
    static let baseURL: String = {
        if let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String {
            print("BASE_URL: \(baseURL)")
            return baseURL
        }
        fatalError("BASE_URL not found in Info.plist")
    }()
} 