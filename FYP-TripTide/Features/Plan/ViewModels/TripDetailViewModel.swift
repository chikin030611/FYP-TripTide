import Foundation

class TripDetailViewModel: ObservableObject {
    @Published var trip: Trip
    @Published var touristAttractionsCards: [Card] = []
    @Published var restaurantsCards: [Card] = []
    @Published var lodgingsCards: [Card] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private let placesService = PlacesService.shared
    private let tripsManager = TripsManager.shared
    private var currentTask: Task<Void, Never>?
    
    init(trip: Trip) {
        self.trip = trip
    }

    @MainActor
    func fetchPlaces() async {
        // Cancel any existing task
        currentTask?.cancel()
        
        // Create new task
        currentTask = Task {
            print("🔄 Starting fetchPlaces()")
            isLoading = true
            error = nil
            
            do {
                // Check if task is cancelled
                try Task.checkCancellation()
                
                print("📱 Fetching trip data...")
                if let updatedTrip = try await tripsManager.fetchTrip(id: trip.id) {
                    print("✅ Trip data fetched successfully")
                    self.trip = updatedTrip
                }
                
                // Check again for cancellation
                try Task.checkCancellation()
                
                print("📱 Starting to fetch places...")
                print("🏛️ Fetching tourist attractions for IDs: \(trip.touristAttractionsIds)")
                let touristAttractions = try await fetchPlacesById(ids: trip.touristAttractionsIds)
                try Task.checkCancellation()
                
                print("🍽️ Fetching restaurants for IDs: \(trip.restaurantsIds)")
                let restaurants = try await fetchPlacesById(ids: trip.restaurantsIds)
                try Task.checkCancellation()
                
                print("🏨 Fetching lodgings for IDs: \(trip.lodgingsIds)")
                let lodgings = try await fetchPlacesById(ids: trip.lodgingsIds)
                
                print("📝 Updating cards...")
                touristAttractionsCards = touristAttractions.map { Card(place: $0.toPlace()) }
                restaurantsCards = restaurants.map { Card(place: $0.toPlace()) }
                lodgingsCards = lodgings.map { Card(place: $0.toPlace()) }
                
                print("✅ All places fetched and cards updated successfully")
                
            } catch is CancellationError {
                print("🚫 Task was cancelled")
                return
            } catch {
                print("❌ Error occurred: \(error)")
                if let apiError = error as? APIError {
                    print("🌐 API Error: \(apiError.localizedDescription)")
                    self.error = apiError.localizedDescription
                } else {
                    print("⚠️ General Error: \(error.localizedDescription)")
                    self.error = error.localizedDescription
                }
            }
            
            print("🏁 Setting isLoading to false")
            isLoading = false
        }
        
        await currentTask?.value
    }
    
    private func fetchPlacesById(ids: [String]) async throws -> [PlaceBasicData] {
        print("📥 fetchPlacesById started for \(ids.count) places")
        return try await withThrowingTaskGroup(of: PlaceBasicData.self) { group in
            // Create a task for each place ID
            for id in ids {
                group.addTask {
                    print("🔍 Fetching place with ID: \(id)")
                    let place = try await self.placesService.fetchPlaceBasicById(id: id)
                    print("✅ Successfully fetched place: \(id)")
                    return place
                }
            }
            
            // Collect results
            var places: [PlaceBasicData] = []
            for try await place in group {
                places.append(place)
                print("📍 Added place to results (total: \(places.count))")
            }
            
            print("✅ Completed fetching all places. Total: \(places.count)")
            return places
        }
    }

    @MainActor
    func fetchTrip() async throws {
        do {
            if let updatedTrip = try await tripsManager.fetchTrip(id: trip.id) {
                self.trip = updatedTrip
            }
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    deinit {
        currentTask?.cancel()
    }
}
