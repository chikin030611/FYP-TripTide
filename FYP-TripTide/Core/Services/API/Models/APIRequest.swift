import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
} 

enum APIError: Error, Equatable {
    case invalidURL
    case decodingError
    case networkError
    case unauthorized
    case invalidResponse
    case serverError(statusCode: Int)
    case serverErrorWithMessage(statusCode: Int, message: String)
    case placeAlreadyInTrip
    case notFound
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        case .serverErrorWithMessage(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
        case .decodingError:
            return "Decoding error"
        case .networkError:
            return "Network error"
        case .placeAlreadyInTrip:
            return "This place is already in your trip"
        case .notFound:
            return "Not found"
        }
    }
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL), 
             (.decodingError, .decodingError),
             (.networkError, .networkError),
             (.unauthorized, .unauthorized),
             (.invalidResponse, .invalidResponse),
             (.placeAlreadyInTrip, .placeAlreadyInTrip),
             (.notFound, .notFound):
            return true
        case let (.serverError(lhsCode), .serverError(rhsCode)):
            return lhsCode == rhsCode
        case let (.serverErrorWithMessage(lhsCode, lhsMsg), .serverErrorWithMessage(rhsCode, rhsMsg)):
            return lhsCode == rhsCode && lhsMsg == rhsMsg
        default:
            return false
        }
    }
}