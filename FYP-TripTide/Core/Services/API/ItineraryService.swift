import Foundation

class ItineraryService {
    static let shared = ItineraryService()
    private let baseURL = APIConfig.baseURL
    
    private init() {}
    
    func createItinerary(tripId: String, day: Int, scheduledPlaces: [ScheduledPlaceDto]) async throws -> DailyItinerary {
        print("🔍 ItineraryService: Starting createItinerary for trip \(tripId), day \(day)")
        
        guard let token = await AuthManager.shared.token else {
            print("❌ ItineraryService: Missing auth token")
            throw APIError.unauthorized
        }
        
        guard let url = URL(string: "\(baseURL)/trips/\(tripId)/itineraries") else {
            print("❌ ItineraryService: Invalid URL \(baseURL)/trips/\(tripId)/itineraries")
            throw APIError.invalidURL
        }
        
        // Create request body
        let requestBody = CreateItineraryRequest(day: day, scheduledPlaces: scheduledPlaces)
        print("📤 ItineraryService: Request payload - Day: \(day), Places: \(scheduledPlaces.count)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            print("📝 ItineraryService: Request body encoded successfully")
        } catch {
            print("❌ ItineraryService: Failed to encode request body: \(error)")
            throw APIError.invalidResponse
        }
        
        do {
            print("🔄 ItineraryService: Sending API request to \(url.absoluteString)")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ ItineraryService: Invalid HTTP response type")
                throw APIError.invalidResponse
            }
            
            print("📥 ItineraryService: Received response with status code: \(httpResponse.statusCode)")
            
            // Handle response status code
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    
                    // First decode to ItineraryResponse which matches the server structure
                    let response = try decoder.decode(ItineraryResponse.self, from: data)
                    print("✅ ItineraryService: Successfully decoded response for day: \(response.day)")
                    
                    // Then convert to your app's DailyItinerary model
                    let result = response.toDailyItinerary(tripId: tripId)
                    print("✅ ItineraryService: Successfully created itinerary with ID: \(result.id)")
                    
                    // Add this line to refresh the Trip cache after successful itinerary creation
                    Task {
                        await TripsManager.shared.invalidateTripCache(tripId: tripId)
                    }
                    
                    return result
                } catch {
                    print("❌ ItineraryService: Decoding error: \(error)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📄 ItineraryService: Raw JSON response: \(jsonString)")
                    }
                    throw APIError.decodingError
                }
            case 401:
                print("❌ ItineraryService: Unauthorized (401)")
                throw APIError.unauthorized
            case 404:
                print("❌ ItineraryService: Resource not found (404)")
                throw APIError.invalidURL
            default:
                print("❌ ItineraryService: Server error with status code: \(httpResponse.statusCode)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 ItineraryService: Error response: \(jsonString)")
                }
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }
        } catch let urlError as URLError {
            print("❌ ItineraryService: Network error: \(urlError.localizedDescription)")
            throw APIError.networkError
        } catch let apiError as APIError {
            print("❌ ItineraryService: API error: \(apiError.localizedDescription)")
            throw apiError
        } catch {
            print("❌ ItineraryService: Unexpected error: \(error.localizedDescription)")
            throw APIError.invalidResponse
        }
    }
}

