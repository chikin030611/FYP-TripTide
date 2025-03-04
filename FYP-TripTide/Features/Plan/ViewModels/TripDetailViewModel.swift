import Foundation

class TripDetailViewModel: ObservableObject {
    @Published var trip: Trip
    @Published var touristAttractionsCards: [Card] = []
    @Published var restaurantsCards: [Card] = []
    @Published var lodgingsCards: [Card] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private let placesAPI = PlacesAPIController.shared
    private let tripsAPI = TripsAPIController.shared

    init(trip: Trip) {
        self.trip = trip
    }

    @MainActor
    func fetchPlaces() async {
        isLoading = true
        error = nil
        
        do {
            // First refresh the trip data
            if let updatedTrip = try await tripsAPI.fetchTrip(id: trip.id) {
                self.trip = updatedTrip
            }
            
            // Then fetch all places
            async let touristAttractions = fetchPlacesById(ids: trip.touristAttractionsIds)
            async let restaurants = fetchPlacesById(ids: trip.restaurantsIds)
            async let lodgings = fetchPlacesById(ids: trip.lodgingsIds)
            
            let (fetchedAttractions, fetchedRestaurants, fetchedLodgings) = try await (touristAttractions, restaurants, lodgings)
            
            touristAttractionsCards = fetchedAttractions.map { Card(place: $0.toPlace()) }
            restaurantsCards = fetchedRestaurants.map { Card(place: $0.toPlace()) }
            lodgingsCards = fetchedLodgings.map { Card(place: $0.toPlace()) }
            
            isLoading = false
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
            } else {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    private func fetchPlacesById(ids: [String]) async throws -> [PlaceBasicData] {
        try await withThrowingTaskGroup(of: PlaceBasicData.self) { group in
            // Create a task for each place ID
            for id in ids {
                group.addTask {
                    try await self.placesAPI.fetchPlaceBasicById(id: id)
                }
            }
            
            // Collect results
            var places: [PlaceBasicData] = []
            for try await place in group {
                places.append(place)
            }
            
            return places
        }
    }
}
