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
    
    func fetchItinerary(tripId: String, day: Int) async throws -> DailyItinerary {
        print("🔍 ItineraryService: Fetching itinerary for trip \(tripId), day \(day)")
        
        guard let token = await AuthManager.shared.token else {
            print("❌ ItineraryService: Missing auth token")
            throw APIError.unauthorized
        }
        
        // Use the endpoint that fetches all itineraries
        guard let url = URL(string: "\(baseURL)/trips/\(tripId)/itineraries") else {
            print("❌ ItineraryService: Invalid URL \(baseURL)/trips/\(tripId)/itineraries")
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            print("🔄 ItineraryService: Sending API request to \(url.absoluteString)")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ ItineraryService: Invalid HTTP response type")
                throw APIError.invalidResponse
            }
            
            print("📥 ItineraryService: Received response with status code: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    
                    // Debug the JSON for troubleshooting
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📄 ItineraryService: Raw JSON response: \(jsonString)")
                    }
                    
                    // Decode as array of ItineraryResponse
                    let responses = try decoder.decode([ItineraryResponse].self, from: data)
                    print("✅ ItineraryService: Successfully decoded \(responses.count) itineraries")
                    
                    // Find the itinerary for the requested day
                    if let response = responses.first(where: { $0.day == day }) {
                        print("✅ ItineraryService: Found itinerary for day \(day)")
                        let result = response.toDailyItinerary(tripId: tripId)
                        return result
                    } else {
                        print("❌ ItineraryService: No itinerary found for day \(day)")
                        throw APIError.notFound
                    }
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
                throw APIError.notFound
            default:
                print("❌ ItineraryService: Server error with status code: \(httpResponse.statusCode)")
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
    
    func updateItinerary(tripId: String, day: Int, scheduledPlaces: [ScheduledPlaceDto]) async throws -> DailyItinerary {
        print("🔍 ItineraryService: Updating itinerary for trip \(tripId), day \(day)")
        
        guard let token = await AuthManager.shared.token else {
            print("❌ ItineraryService: Missing auth token")
            throw APIError.unauthorized
        }
        
        guard let url = URL(string: "\(baseURL)/trips/\(tripId)/itineraries/\(day)") else {
            print("❌ ItineraryService: Invalid URL \(baseURL)/trips/\(tripId)/itineraries/\(day)")
            throw APIError.invalidURL
        }
        
        // Create UpdateItineraryRequest object wrapping the scheduledPlaces array
        let requestBody = UpdateItineraryRequest(scheduledPlaces: scheduledPlaces)
        print("📤 ItineraryService: Request payload - Places: \(scheduledPlaces.count)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            // Encode the UpdateItineraryRequest object
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
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    
                    let response = try decoder.decode(ItineraryResponse.self, from: data)
                    print("✅ ItineraryService: Successfully decoded response for day: \(response.day)")
                    
                    let result = response.toDailyItinerary(tripId: tripId)
                    print("✅ ItineraryService: Successfully updated itinerary with ID: \(result.id)")
                    
                    // Refresh the Trip cache after successful update
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
                throw APIError.notFound
            default:
                print("❌ ItineraryService: Server error with status code: \(httpResponse.statusCode)")
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

