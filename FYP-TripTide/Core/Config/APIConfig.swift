import Foundation

enum APIConfig {
    static let baseURL: String = {
        if let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String {
            return baseURL
        }
        fatalError("BASE_URL not found in Info.plist")
    }()

    static let googleMapsAPIKey: String = {
        if let googleMapsAPIKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String {
            return googleMapsAPIKey
        }
        fatalError("GOOGLE_MAPS_API_KEY not found in Info.plist")
    }()
} 