import Foundation

class TripsService {
    private let baseURL = APIConfig.baseURL
    
    func fetchTrips() async throws -> [Trip] {
        guard let url = URL(string: "\(baseURL)/trips") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = await AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.unauthorized
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        
        let tripResponses = try decoder.decode([TripResponse].self, from: data)
        return tripResponses.map { $0.toTrip() }
    }
    
    func updateTrip(_ trip: Trip) async throws {
        guard let url = URL(string: "\(baseURL)/trips/\(trip.id)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = await AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.unauthorized
        }
        
        // Create request body
        let tripRequest = UpdateTripRequest(
            name: trip.name,
            description: trip.description,
            startDate: trip.startDate,
            endDate: trip.endDate
        )
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(tripRequest)
        
        // Print request for debugging
        if let body = request.httpBody, let str = String(data: body, encoding: .utf8) {
            print("Request body: \(str)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Print response for debugging
        if let str = String(data: data, encoding: .utf8) {
            print("Response: \(str)")
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    func deleteTrip(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/trips/\(id)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = await AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.unauthorized
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    func fetchTrip(id: String) async throws -> Trip? {
        guard let url = URL(string: "\(baseURL)/trips/\(id)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = await AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.unauthorized
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        
        let tripResponse = try decoder.decode(TripResponse.self, from: data)
        return tripResponse.toTrip()
    }

    func createTrip(trip: Trip) async throws -> Trip {
        guard let url = URL(string: "\(baseURL)/trips") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = await AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.unauthorized
        }
        
        let tripRequest = CreateTripRequest(
            name: trip.name,
            description: trip.description,
            startDate: trip.startDate,
            endDate: trip.endDate,
            image: trip.image
        )

        print("Trip request: \(tripRequest)")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(tripRequest)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970

        let tripResponse = try decoder.decode(TripResponse.self, from: data)
        return tripResponse.toTrip()
    }

    func checkPlaceInTrip(tripId: String, placeId: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/trips/\(tripId)/places/\(placeId)/check") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = await AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.unauthorized
        }
        
        // Print request details for debugging
        print("📤 checkPlaceInTrip Request URL: \(url)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Print response data for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 checkPlaceInTrip Response Data: \(responseString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("📥 checkPlaceInTrip Response Status Code: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to extract error message from response body
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Server error response body: \(errorString)")
                
                // Try to parse as JSON for more details
                if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("❌ Parsed error details: \(errorDict)")
                    
                    // If there's a specific error message, include it in the error
                    if let message = errorDict["message"] as? String {
                        throw APIError.serverErrorWithMessage(statusCode: httpResponse.statusCode, message: message)
                    }
                }
            }
            
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(Bool.self, from: data)
    }

    func addPlaceToTrip(tripId: String, placeId: String, placeType: String) async throws {
        print("⭐️ Starting addPlaceToTrip - tripId: \(tripId), placeId: \(placeId), placeType: \(placeType)")
        
        guard let url = URL(string: "\(baseURL)/trips/\(tripId)/places") else {
            print("❌ Invalid URL error")
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = await AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("❌ No authorization token found")
            throw APIError.unauthorized
        }
        
        let body = [
            "placeId": placeId,
            "placeType": placeType
        ]
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        
        // Print request details
        print("📤 Request URL: \(url)")
        print("📤 Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            print("📤 Request Body: \(bodyString)")
        }
        
        let (data, response) = try await URLSession.shared.upload(
            for: request,
            from: request.httpBody ?? Data()
        )
        
        // Print response details
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Response Data: \(responseString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw APIError.invalidResponse
        }
        
        print("📥 Response Status Code: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode == 401 {
            print("❌ Unauthorized error")
            throw APIError.unauthorized
        }
        
        // Check for 400 Bad Request specifically for "Place already in trip"
        if httpResponse.statusCode == 400 {
            // Try to decode the error response as a dictionary
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Error response body: \(errorString)")
            }
            
            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("❌ Parsed error details: \(errorDict)")
                
                if let message = errorDict["message"] as? String {
                    if message == "Place already in trip" {
                        print("⚠️ Place is already in trip")
                        throw APIError.placeAlreadyInTrip
                    } else {
                        throw APIError.serverErrorWithMessage(statusCode: httpResponse.statusCode, message: message)
                    }
                }
            }
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Server error with status code: \(httpResponse.statusCode)")
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        print("✅ Successfully added place to trip")
    }

    func removePlaceFromTrip(tripId: String, placeId: String) async throws {
        guard let url = URL(string: "\(baseURL)/trips/\(tripId)/places/\(placeId)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = await AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.unauthorized
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        print("successfully removed place from trip")

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}

