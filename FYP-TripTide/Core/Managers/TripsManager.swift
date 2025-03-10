import Foundation

class TripsManager: ObservableObject {
    @Published private(set) var trips: [Trip] = []
    @Published private(set) var isLoading = false
    @Published var error: String?
    
    static let shared = TripsManager()
    private let tripsAPI = TripsService()
    
    // Cache-related properties
    private var lastCacheTime: Date?
    private let cacheExpirationTime: TimeInterval = 5 * 60 // 5 minutes cache expiration
    private var tripCache: [String: Trip] = [:] // Cache individual trips by ID
    
    // Place-in-trip cache
    private var placeTripCache: [String: [String: Bool]] = [:] // [tripId: [placeId: isInTrip]]
    private var placeTripCacheTime: [String: [String: Date]] = [:] // [tripId: [placeId: lastCheckedTime]]
    private let placeCacheExpirationTime: TimeInterval = 2 * 60 // 2 minutes cache expiration for place status
    
    private init() {}
    
    // Check if cache is valid
    private func isCacheValid() -> Bool {
        guard let lastCacheTime = lastCacheTime else { return false }
        return Date().timeIntervalSince(lastCacheTime) < cacheExpirationTime
    }
    
    // Get a trip from cache if available
    private func getCachedTrip(id: String) -> Trip? {
        return tripCache[id]
    }
    
    // Add a trip to the cache
    private func cacheTrip(_ trip: Trip) {
        tripCache[trip.id] = trip
    }
    
    // Clear the cache
    private func clearCache() {
        tripCache.removeAll()
        lastCacheTime = nil
        placeTripCache.removeAll()
        placeTripCacheTime.removeAll()
    }
    
    // Check if place-in-trip cache is valid
    private func isPlaceTripCacheValid(tripId: String, placeId: String) -> Bool {
        guard let tripCache = placeTripCacheTime[tripId],
              let lastCheckedTime = tripCache[placeId] else {
            return false
        }
        return Date().timeIntervalSince(lastCheckedTime) < placeCacheExpirationTime
    }
    
    // Get cached place-in-trip status
    private func getCachedPlaceInTripStatus(tripId: String, placeId: String) -> Bool? {
        if isPlaceTripCacheValid(tripId: tripId, placeId: placeId) {
            return placeTripCache[tripId]?[placeId]
        }
        return nil
    }
    
    // Cache place-in-trip status
    private func cachePlaceInTripStatus(tripId: String, placeId: String, isInTrip: Bool) {
        // Initialize dictionaries if they don't exist
        if placeTripCache[tripId] == nil {
            placeTripCache[tripId] = [:]
        }
        if placeTripCacheTime[tripId] == nil {
            placeTripCacheTime[tripId] = [:]
        }
        
        // Store the status and current time
        placeTripCache[tripId]?[placeId] = isInTrip
        placeTripCacheTime[tripId]?[placeId] = Date()
    }
    
    // Invalidate place-in-trip cache for a specific trip
    private func invalidatePlaceTripCache(tripId: String) {
        placeTripCache.removeValue(forKey: tripId)
        placeTripCacheTime.removeValue(forKey: tripId)
    }
    
    @MainActor
    func fetchTrips(forceRefresh: Bool = false) async {
        // Return cached trips if cache is valid and not forcing refresh
        if !forceRefresh && isCacheValid() && !trips.isEmpty {
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            trips = try await tripsAPI.fetchTrips()
            
            // Update the cache
            lastCacheTime = Date()
            for trip in trips {
                cacheTrip(trip)
            }
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
            } else {
                self.error = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    @MainActor
    func createTrip(_ trip: Trip) async throws -> Trip {
        isLoading = true
        error = nil
        
        do {
            let newTrip = try await tripsAPI.createTrip(trip: trip)
            trips.append(newTrip)
            
            // Add to cache
            cacheTrip(newTrip)
            
            return newTrip
        } catch {   
            isLoading = false
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
                throw apiError
            } else {
                self.error = error.localizedDescription
                throw error
            }
        }
    }
    
    @MainActor
    func updateTrip(_ trip: Trip) async throws {
        isLoading = true
        error = nil
        
        do {
            try await tripsAPI.updateTrip(trip)
            if let index = trips.firstIndex(where: { $0.id == trip.id }) {
                trips[index] = trip
            }
            
            // Update cache
            cacheTrip(trip)
            
            // Invalidate place-trip cache for this trip since it's been modified
            invalidatePlaceTripCache(tripId: trip.id)
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
                throw apiError
            } else {
                self.error = error.localizedDescription
                throw error
            }
        }
        isLoading = false
    }
    
    @MainActor
    func deleteTrip(id: String) async throws {
        isLoading = true
        error = nil
        
        do {
            try await tripsAPI.deleteTrip(id: id)
            trips.removeAll { $0.id == id }
            
            // Remove from cache
            tripCache.removeValue(forKey: id)
            
            // Remove from place-trip cache
            invalidatePlaceTripCache(tripId: id)
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
                throw apiError
            } else {
                self.error = error.localizedDescription
                throw error
            }
        }
        isLoading = false
    }
    
    @MainActor
    func fetchTrip(id: String, forceRefresh: Bool = false) async throws -> Trip? {
        // Check cache first if not forcing refresh
        if !forceRefresh, let cachedTrip = getCachedTrip(id: id) {
            return cachedTrip
        }
        
        isLoading = true
        error = nil
        
        do {
            let trip = try await tripsAPI.fetchTrip(id: id)
            if let trip = trip {
                if let index = trips.firstIndex(where: { $0.id == id }) {
                    trips[index] = trip
                }
                
                // Update cache
                cacheTrip(trip)
            }
            return trip
        } catch {
            isLoading = false
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
                throw apiError
            } else {
                self.error = error.localizedDescription
                throw error
            }
        } 
    }
    
    @MainActor
    func addPlaceToTrip(tripId: String, placeId: String, placeType: String) async throws {
        isLoading = true
        error = nil
        
        do {
            try await tripsAPI.addPlaceToTrip(tripId: tripId, placeId: placeId, placeType: placeType)
            
            // Update place-trip cache
            cachePlaceInTripStatus(tripId: tripId, placeId: placeId, isInTrip: true)
            
            // Invalidate the trip cache for this trip since it's been modified
            tripCache.removeValue(forKey: tripId)
            
            // Refresh the trip data
            _ = try await fetchTrip(id: tripId, forceRefresh: true)
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
                throw apiError
            } else {
                self.error = error.localizedDescription
                throw error
            }
        }
        
        isLoading = false
    }
    
    @MainActor
    func checkPlaceInTrip(tripId: String, placeId: String, forceRefresh: Bool = false) async throws -> Bool {
        // Check cache first if not forcing refresh
        if !forceRefresh, let cachedStatus = getCachedPlaceInTripStatus(tripId: tripId, placeId: placeId) {
            return cachedStatus
        }
        
        do {
            let isInTrip = try await tripsAPI.checkPlaceInTrip(tripId: tripId, placeId: placeId)
            
            // Cache the result
            cachePlaceInTripStatus(tripId: tripId, placeId: placeId, isInTrip: isInTrip)
            
            return isInTrip
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
                
                // Log detailed error information
                print("API Error in checkPlaceInTrip: \(apiError)")
                
                switch apiError {
                case .serverError(let statusCode):
                    print("Server error with status code: \(statusCode)")
                case .serverErrorWithMessage(let statusCode, let message):
                    print("Server error with status code: \(statusCode), message: \(message)")
                default:
                    break
                }
                
                throw apiError
            } else {
                self.error = error.localizedDescription
                print("Non-API Error in checkPlaceInTrip: \(error)")
                print("Error type: \(type(of: error))")
                print("Error description: \(error.localizedDescription)")
                
                throw error
            }
        }
    }
    
    // Helper method to check if a place is in any trip (with caching)
    @MainActor
    func isPlaceInAnyTrip(placeId: String) async -> Bool {
        // First check if we have any cached positive results
        for (tripId, placeMap) in placeTripCache {
            if let isInTrip = placeMap[placeId], isInTrip, 
               isPlaceTripCacheValid(tripId: tripId, placeId: placeId) {
                print("Cache hit: Place \(placeId) is in trip \(tripId)")
                return true
            }
        }
        
        // If no positive cache hits, check each trip
        for trip in trips {
            do {
                print("Checking if place \(placeId) is in trip \(trip.id)")
                if try await checkPlaceInTrip(tripId: trip.id, placeId: placeId) {
                    return true
                }
            } catch {
                print("Error checking if place is in trip: \(error)")
                print("Error details: \(error.localizedDescription)")
                
                // If it's an API error, log more details
                if let apiError = error as? APIError {
                    print("API Error type: \(apiError)")
                    
                    switch apiError {
                    case .serverError(let statusCode):
                        print("Server error with status code: \(statusCode)")
                    case .serverErrorWithMessage(let statusCode, let message):
                        print("Server error with status code: \(statusCode), message: \(message)")
                    default:
                        break
                    }
                }
                
                // Continue checking other trips even if one fails
                continue
            }
        }
        return false
    }
    
    @MainActor
    func removePlaceFromTrip(tripId: String, placeId: String) async throws {
        isLoading = true
        error = nil
        
        do {
            print("Removing place from trip: \(tripId) and place: \(placeId)")
            try await tripsAPI.removePlaceFromTrip(tripId: tripId, placeId: placeId)
            
            // Update place-trip cache
            cachePlaceInTripStatus(tripId: tripId, placeId: placeId, isInTrip: false)
            
            // Invalidate the trip cache for this trip since it's been modified
            tripCache.removeValue(forKey: tripId)
            
            // Refresh the trip data
            _ = try await fetchTrip(id: tripId, forceRefresh: true)
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
                throw apiError
            } else {
                self.error = error.localizedDescription
                throw error
            }
        }
        
        isLoading = false
    }
    
    // Force refresh all cached data
    @MainActor
    func refreshAllData() async {
        clearCache()
        await fetchTrips(forceRefresh: true)
    }
} 