import Foundation
import Combine

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
    
    // Track if initial data has been loaded
    private var hasLoadedInitialData = false
    
    // Store cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // Static view model store - maintains one view model per trip ID
    private static var viewModelStore = [String: TripDetailViewModel]()
    
    // Factory method to create or retrieve existing view model
    static func viewModel(for trip: Trip) -> TripDetailViewModel {
        if let existingViewModel = viewModelStore[trip.id] {
            print("♻️ Reusing existing view model for trip: \(trip.name) (ID: \(trip.id))")
            // Update the trip data in case it changed
            if existingViewModel.trip.name != trip.name || 
               existingViewModel.trip.touristAttractionsIds.count != trip.touristAttractionsIds.count ||
               existingViewModel.trip.restaurantsIds.count != trip.restaurantsIds.count ||
               existingViewModel.trip.lodgingsIds.count != trip.lodgingsIds.count {
                print("🔄 Trip data changed, updating view model")
                existingViewModel.trip = trip
                // Refresh data if needed
                Task {
                    await existingViewModel.fetchPlaces()
                }
            }
            return existingViewModel
        }
        
        print("🆕 Creating new view model for trip: \(trip.name) (ID: \(trip.id))")
        let newViewModel = TripDetailViewModel(trip: trip)
        viewModelStore[trip.id] = newViewModel
        return newViewModel
    }
    
    // Use internal access (default) instead of fileprivate
    init(trip: Trip) {
        print("📱 TripDetailViewModel initialized with trip: \(trip.name) (ID: \(trip.id))")
        print("📊 Initial card counts - Tourist Attractions: \(trip.touristAttractionsIds.count) IDs, Restaurants: \(trip.restaurantsIds.count) IDs, Lodgings: \(trip.lodgingsIds.count) IDs")
        
        self.trip = trip
        
        // Set up notification observers at the ViewModel level
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        // Clean up any existing cancellables first
        cancellables.removeAll()
        
        // Listen for place added/removed notifications with proper trip ID validation
        NotificationCenter.default.publisher(for: .placeAddedToTrip)
            .sink { [weak self] notification in
                guard let self = self,
                      let notificationTripId = notification.object as? String,
                      notificationTripId == self.trip.id else { return }
                
                print("📣 ViewModel received placeAddedToTrip notification for trip: \(self.trip.id)")
                // Use a more efficient approach that doesn't recreate the entire view
                self.refreshTripData()
            }
            .store(in: &cancellables)
            
        NotificationCenter.default.publisher(for: .placeRemovedFromTrip)
            .sink { [weak self] notification in
                guard let self = self,
                      let notificationTripId = notification.object as? String, 
                      notificationTripId == self.trip.id else { return }
                
                print("📣 ViewModel received placeRemovedFromTrip notification for trip: \(self.trip.id)")
                // Use a more efficient approach that doesn't recreate the entire view
                self.refreshTripData()
            }
            .store(in: &cancellables)
    }
    
    // Add a more efficient method to refresh just the trip data
    private func refreshTripData() {
        Task { @MainActor in
            await fetchPlaces()
        }
    }

    @MainActor
    func fetchPlaces() async {
        // Cancel any existing task
        currentTask?.cancel()
        
        // Create new task
        currentTask = Task {
            print("🔄 Starting fetchPlaces() for trip: \(trip.name) (ID: \(trip.id))")
            isLoading = true
            error = nil
            
            do {
                // Check if task is cancelled
                try Task.checkCancellation()
                
                print("📱 Fetching trip data...")
                if let updatedTrip = try await tripsManager.fetchTrip(id: trip.id) {
                    print("✅ Trip data fetched successfully")
                    self.trip = updatedTrip
                    print("📊 Updated trip IDs - Tourist Attractions: \(updatedTrip.touristAttractionsIds.count), Restaurants: \(updatedTrip.restaurantsIds.count), Lodgings: \(updatedTrip.lodgingsIds.count)")
                }
                
                // Check again for cancellation
                try Task.checkCancellation()
                
                print("📱 Starting to fetch places...")
                
                // Fetch all place types concurrently for better performance
                async let touristAttractionsTask = fetchPlacesById(ids: trip.touristAttractionsIds)
                async let restaurantsTask = fetchPlacesById(ids: trip.restaurantsIds)
                async let lodgingsTask = fetchPlacesById(ids: trip.lodgingsIds)
                
                let (touristAttractions, restaurants, lodgings) = try await (touristAttractionsTask, restaurantsTask, lodgingsTask)
                
                print("✅ All places fetched - Tourist attractions: \(touristAttractions.count), Restaurants: \(restaurants.count), Lodgings: \(lodgings.count)")
                
                // Update cards
                print("📝 Updating cards...")
                touristAttractionsCards = touristAttractions.map { Card(place: $0.toPlace()) }
                restaurantsCards = restaurants.map { Card(place: $0.toPlace()) }
                lodgingsCards = lodgings.map { Card(place: $0.toPlace()) }
                
                print("✅ All cards updated - Tourist Attractions: \(touristAttractionsCards.count), Restaurants: \(restaurantsCards.count), Lodgings: \(lodgingsCards.count)")
                
                // Mark that we've loaded initial data
                hasLoadedInitialData = true
                
            } catch is CancellationError {
                print("🚫 Task was cancelled for trip: \(trip.id)")
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
            
            print("🏁 Setting isLoading to false for trip: \(trip.id)")
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
        print("🗑️ TripDetailViewModel deinit for trip: \(trip.id)")
        currentTask?.cancel()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        // Remove from store when deallocated
        TripDetailViewModel.viewModelStore.removeValue(forKey: trip.id)
    }
}

// Helper class to hold weak references
class WeakReference<T: AnyObject> {
    weak var object: T?
    
    init(object: T) {
        self.object = object
    }
}
