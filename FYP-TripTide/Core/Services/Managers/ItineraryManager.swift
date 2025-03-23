import Foundation

class ItineraryManager {
    static let shared = ItineraryManager()
    
    private let itineraryService = ItineraryService.shared
    
    // Cache system: Dictionary mapping trip IDs to their itineraries
    private var itinerariesCache: [String: [DailyItinerary]] = [:]
    private var lastFetchTime: [String: Date] = [:]
    
    // Cache expiration time (5 minutes)
    private let cacheExpirationInterval: TimeInterval = 300
    
    private init() {}
    
    /// Fetches all itineraries for a trip, using cache if valid
    func fetchAllItineraries(tripId: String, forceRefresh: Bool = false) async throws -> [DailyItinerary] {
        print("🔍 ItineraryManager: Fetching all itineraries for trip \(tripId), forceRefresh: \(forceRefresh)")
        
        // Check if we can use cached data
        if !forceRefresh, 
           let cachedItineraries = itinerariesCache[tripId],
           let lastFetch = lastFetchTime[tripId],
           Date().timeIntervalSince(lastFetch) < cacheExpirationInterval {
            print("✅ ItineraryManager: Using cached itineraries for trip \(tripId)")
            return cachedItineraries
        }
        
        // Otherwise fetch fresh data from API
        do {
            let itineraries = try await itineraryService.fetchAllItineraries(tripId: tripId)
            
            // Update cache
            itinerariesCache[tripId] = itineraries
            lastFetchTime[tripId] = Date()
            
            print("📦 ItineraryManager: Updated cache with \(itineraries.count) itineraries for trip \(tripId)")
            return itineraries
        } catch {
            print("❌ ItineraryManager: Error fetching itineraries: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Fetches a specific day's itinerary using the cache if possible
    func fetchItinerary(tripId: String, day: Int, forceRefresh: Bool = false) async throws -> DailyItinerary {
        print("🔍 ItineraryManager: Fetching itinerary for trip \(tripId), day \(day)")
        
        // Try to get all itineraries first (using cache if valid)
        let allItineraries = try await fetchAllItineraries(tripId: tripId, forceRefresh: forceRefresh)
        
        // Find the specific day's itinerary
        if let itinerary = allItineraries.first(where: { $0.dayNumber == day }) {
            return itinerary
        } else {
            print("❌ ItineraryManager: No itinerary found for day \(day)")
            throw APIError.notFound
        }
    }
    
    /// Creates a new itinerary and updates the cache
    func createItinerary(tripId: String, day: Int, scheduledPlaces: [ScheduledPlaceDto]) async throws -> DailyItinerary {
        print("🔧 ItineraryManager: Creating itinerary for trip \(tripId), day \(day)")
        
        let itinerary = try await itineraryService.createItinerary(tripId: tripId, day: day, scheduledPlaces: scheduledPlaces)
        
        // Update cache by adding/replacing this day's itinerary
        updateCacheWithItinerary(tripId: tripId, itinerary: itinerary)
        
        return itinerary
    }
    
    /// Updates an existing itinerary and updates the cache
    func updateItinerary(tripId: String, day: Int, scheduledPlaces: [ScheduledPlaceDto]) async throws -> DailyItinerary {
        print("🔧 ItineraryManager: Updating itinerary for trip \(tripId), day \(day)")
        
        let itinerary = try await itineraryService.updateItinerary(tripId: tripId, day: day, scheduledPlaces: scheduledPlaces)
        
        // Update cache by adding/replacing this day's itinerary
        updateCacheWithItinerary(tripId: tripId, itinerary: itinerary)
        
        return itinerary
    }
    
    /// Invalidates the cache for a specific trip
    func invalidateItineraryCache(tripId: String) {
        print("🧹 ItineraryManager: Invalidating cache for trip \(tripId)")
        itinerariesCache.removeValue(forKey: tripId)
        lastFetchTime.removeValue(forKey: tripId)
    }
    
    /// Updates the cache with a new/modified itinerary
    private func updateCacheWithItinerary(tripId: String, itinerary: DailyItinerary) {
        // If we have cached itineraries for this trip
        if var cachedItineraries = itinerariesCache[tripId] {
            // Try to find and replace existing day
            if let index = cachedItineraries.firstIndex(where: { $0.dayNumber == itinerary.dayNumber }) {
                cachedItineraries[index] = itinerary
            } else {
                // Or add new day
                cachedItineraries.append(itinerary)
            }
            
            // Update cache
            itinerariesCache[tripId] = cachedItineraries
            lastFetchTime[tripId] = Date()
            
            print("📦 ItineraryManager: Updated cache for trip \(tripId), day \(itinerary.dayNumber)")
        } else {
            // Start new cache entry for this trip
            itinerariesCache[tripId] = [itinerary]
            lastFetchTime[tripId] = Date()
            
            print("📦 ItineraryManager: Created new cache entry for trip \(tripId)")
        }
    }
} 