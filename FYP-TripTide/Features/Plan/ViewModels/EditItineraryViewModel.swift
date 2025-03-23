import Foundation
import Combine
import SwiftUI

@MainActor
class EditItineraryViewModel: ObservableObject {
    private let itineraryManager = ItineraryManager.shared
    private let placesService = PlacesService.shared
    private let tripId: String
    
    // Inputs
    @Published var day: Int {
        didSet {
            if oldValue != day {
                // Defensive check before accessing dictionary
                if oldValue > 0 {
                    scheduledPlacesByDay[oldValue] = scheduledPlaces
                }
                
                // Update with places for the new day (or empty array if none exist)
                scheduledPlaces = scheduledPlacesByDay[day] ?? []
                
                // If we're in editing mode, try to fetch the itinerary for this day
                if isEditing {
                    // Only fetch if we don't already have data for this day
                    if !scheduledPlacesByDay.keys.contains(day) {
                        Task {
                            await fetchExistingItinerary()
                        }
                    }
                }
                
                // Update UI state
                showDropArea = scheduledPlaces.isEmpty
            }
        }
    }
    @Published var numberOfDays: Int
    @Published var scheduledPlaces: [ScheduledPlaceInput] = []
    
    // Dictionary to store scheduled places for each day
    private var scheduledPlacesByDay: [Int: [ScheduledPlaceInput]] = [:]
    
    // Status
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var isSuccess = false
    @Published var showDropArea = true
    @Published var isEditing = false
    @Published var existingItineraryId: String? = nil
    
    // Available places
    @Published var availablePlaces: [Place] = []
    @Published var touristAttractions: [Place] = []
    @Published var restaurants: [Place] = []
    @Published var lodgings: [Place] = []
    @Published var isLoadingPlaces = false
    
    // Add a property to store all fetched itineraries
    @Published var allItineraries: [DailyItinerary] = []
    
    // Add these properties to track tasks
    private var fetchTask: Task<Void, Never>? = nil
    private var loadPlacesTask: Task<Void, Never>? = nil
    
    init(tripId: String, day: Int, numberOfDays: Int, isEditing: Bool = false) {
        self.tripId = tripId
        self.day = day
        self.numberOfDays = numberOfDays
        self.isEditing = isEditing
        
        // Start loading places immediately using tracked tasks
        loadPlacesTask = Task { 
            await self.loadAvailablePlaces() 
        }
        
        // Always fetch all itineraries, regardless of editing mode
        fetchTask = Task {
            await self.fetchAllItineraries()
        }
    }
    
    // Add a deinit method to cancel tasks
    deinit {
        fetchTask?.cancel()
        loadPlacesTask?.cancel()
        print("EditItineraryViewModel deinit")
    }
    
    func fetchAllItineraries() async {
        guard !isLoading else { return } // Prevent concurrent fetches
        
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            // Add timeout or cancellation check
            let itineraries = try await itineraryManager.fetchAllItineraries(tripId: tripId)
            
            // Check if task was cancelled before updating UI
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                self.allItineraries = itineraries
                
                // Populate scheduledPlacesByDay dictionary for all days
                for itinerary in itineraries {
                    let inputs = itinerary.places.map { place in
                        let input = ScheduledPlaceInput()
                        input.placeId = place.placeId
                        input.startTime = place.startTime
                        input.endTime = place.endTime
                        input.notes = place.notes
                        return input
                    }
                    
                    self.scheduledPlacesByDay[itinerary.dayNumber] = inputs
                    
                    // If this is the current day, update scheduledPlaces
                    if itinerary.dayNumber == self.day {
                        self.existingItineraryId = itinerary.id
                        self.scheduledPlaces = inputs
                        self.showDropArea = inputs.isEmpty
                        
                        // Set isEditing to true if we found an existing itinerary for this day
                        self.isEditing = true
                    }
                }
                
                // If there's no data for the current day, initialize it as empty
                if !self.scheduledPlacesByDay.keys.contains(self.day) {
                    self.scheduledPlaces = []
                    self.scheduledPlacesByDay[self.day] = []
                    self.showDropArea = true
                    
                    // If we're in editing mode but there's no data for this day,
                    // we're actually creating a new itinerary
                    if self.isEditing {
                        self.existingItineraryId = nil
                    }
                }
                
                self.isLoading = false
            }
        } catch let apiError as APIError where apiError == .notFound {
            // If no itineraries exist yet, that's ok
            await MainActor.run {
                self.allItineraries = []
                self.scheduledPlaces = []
                self.showDropArea = true
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load itineraries: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func fetchExistingItinerary() async {
        // If we've already fetched all itineraries, use the cached data
        if !allItineraries.isEmpty {
            await MainActor.run {
                if let itinerary = allItineraries.first(where: { $0.dayNumber == day }) {
                    self.existingItineraryId = itinerary.id
                    
                    // Convert scheduled places to input model if not already in dictionary
                    if !scheduledPlacesByDay.keys.contains(day) {
                        let inputs = itinerary.places.map { place in
                            let input = ScheduledPlaceInput()
                            input.placeId = place.placeId
                            input.startTime = place.startTime
                            input.endTime = place.endTime
                            input.notes = place.notes
                            return input
                        }
                        
                        self.scheduledPlaces = inputs
                        self.scheduledPlacesByDay[day] = inputs
                    } else {
                        self.scheduledPlaces = scheduledPlacesByDay[day] ?? []
                    }
                    
                    self.showDropArea = self.scheduledPlaces.isEmpty
                } else {
                    // No itinerary for this day
                    self.scheduledPlaces = []
                    self.scheduledPlacesByDay[day] = []
                    self.showDropArea = true
                }
            }
            return
        }
        
        // Otherwise, fetch all itineraries
        await fetchAllItineraries()
    }
    
    func loadAvailablePlaces() async {
        await MainActor.run {
            self.isLoadingPlaces = true
        }
        
        do {
            // Load places saved in this trip
            let tripsManager = TripsManager.shared
            if let trip = try await tripsManager.fetchTrip(id: tripId) {
                // Combine all place IDs
                let placeIds = trip.touristAttractionsIds + trip.restaurantsIds + trip.lodgingsIds
                
                let places = try await fetchPlacesById(ids: placeIds)
                
                await MainActor.run {
                    // Convert to Place objects
                    let allPlaces = places.map { $0.toPlace() }
                    self.availablePlaces = allPlaces
                    
                    // Sort places by type
                    self.touristAttractions = allPlaces.filter { $0.type == "tourist_attraction" }
                    self.restaurants = allPlaces.filter { $0.type == "restaurant" }
                    self.lodgings = allPlaces.filter { $0.type == "lodging" }
                    
                    print("📊 Places loaded - Tourist Attractions: \(self.touristAttractions.count), Restaurants: \(self.restaurants.count), Lodgings: \(self.lodgings.count)")
                    
                    self.isLoadingPlaces = false
                }
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load places: \(error.localizedDescription)"
                self.isLoadingPlaces = false
            }
        }
    }

    func addPlace() {
        let newPlace = ScheduledPlaceInput()
        
        // Set default times
        let calendar = Calendar.current
        var startComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        startComponents.hour = 9
        startComponents.minute = 0
        newPlace.startTime = calendar.date(from: startComponents)
        
        var endComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        endComponents.hour = 11
        endComponents.minute = 0
        newPlace.endTime = calendar.date(from: endComponents)
        
        scheduledPlaces.append(newPlace)
        
        // Also update our dictionary
        scheduledPlacesByDay[day] = scheduledPlaces
    }
    
    func removePlaceAt(index: Int) {
        guard index < scheduledPlaces.count else { return }
        scheduledPlaces.remove(at: index)
        
        // Update our dictionary
        scheduledPlacesByDay[day] = scheduledPlaces

        if scheduledPlaces.isEmpty {
            showDropArea = true
            
            // If we're editing and this was the last place, delete the itinerary
            if isEditing && existingItineraryId != nil {
                Task {
                    await deleteItineraryIfEmpty()
                }
            }
        }
    }
    
    func addPlaceWithId(_ placeId: String) {
        let newPlace = ScheduledPlaceInput()
        newPlace.placeId = placeId
        
        // Set default times
        let calendar = Calendar.current
        var startComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        startComponents.hour = 9
        startComponents.minute = 0
        newPlace.startTime = calendar.date(from: startComponents)
        
        var endComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        endComponents.hour = 11
        endComponents.minute = 0
        newPlace.endTime = calendar.date(from: endComponents)
        
        scheduledPlaces.append(newPlace)
        
        // Update our dictionary
        scheduledPlacesByDay[day] = scheduledPlaces
        
        // Hide drop area
        if !scheduledPlaces.isEmpty {
            showDropArea = false
        }
    }
    
    func saveItinerary() async {
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            // Make sure we're working with the current places
            let currentPlaces = scheduledPlaces
            
            let dtos = currentPlaces.compactMap { place -> ScheduledPlaceDto? in
                guard let placeId = place.placeId, !placeId.isEmpty else { return nil }
                
                // Format time strings
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                
                let startTime = place.startTime.map { formatter.string(from: $0) } ?? "00:00:00"
                let endTime = place.endTime.map { formatter.string(from: $0) } ?? "00:00:00"
                
                return ScheduledPlaceDto(
                    placeId: placeId,
                    startTime: startTime,
                    endTime: endTime,
                    notes: place.notes
                )
            }
            
            if isEditing {
                // If we're editing an existing itinerary
                if let existingId = existingItineraryId {
                    if dtos.isEmpty {
                        // If all places were removed, delete the itinerary
                        try await itineraryManager.deleteItinerary(tripId: tripId, day: day)
                        
                        await MainActor.run {
                            self.isSuccess = true
                            self.isLoading = false
                            // Make sure our local state reflects the deletion
                            self.existingItineraryId = nil
                            
                            // Update our allItineraries array too
                            self.allItineraries.removeAll(where: { $0.dayNumber == self.day })
                        }
                    } else {
                        // Otherwise update with the places we have
                        let dailyItinerary = try await itineraryManager.updateItinerary(
                            tripId: tripId,
                            day: day,
                            scheduledPlaces: dtos
                        )
                        
                        await MainActor.run {
                            self.isSuccess = true
                            self.isLoading = false
                        }
                    }
                } else if !dtos.isEmpty {
                    // If there was no existing itinerary but we have places, create a new one
                    let dailyItinerary = try await itineraryManager.createItinerary(
                        tripId: tripId, 
                        day: day,
                        scheduledPlaces: dtos
                    )
                    
                    await MainActor.run {
                        self.existingItineraryId = dailyItinerary.id
                        self.isSuccess = true
                        self.isLoading = false
                    }
                } else {
                    // No existing itinerary and no places - nothing to do
                    await MainActor.run {
                        self.isSuccess = true
                        self.isLoading = false
                    }
                }
            } else {
                // If we're creating a new itinerary, only proceed if we have places
                if !dtos.isEmpty {
                    let dailyItinerary = try await itineraryManager.createItinerary(
                        tripId: tripId, 
                        day: day,
                        scheduledPlaces: dtos
                    )
                    
                    await MainActor.run {
                        self.existingItineraryId = dailyItinerary.id
                        self.isSuccess = true
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.error = "Please add at least one place with a valid ID"
                        self.isLoading = false
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to save itinerary: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func fetchPlacesById(ids: [String]) async throws -> [PlaceBasicData] {
        return try await withThrowingTaskGroup(of: PlaceBasicData.self) { group in
            // Create a task for each place ID
            for id in ids {
                group.addTask {
                    try await self.placesService.fetchPlaceBasicById(id: id)
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
    
    // Convenience method to delete itinerary if all places were removed
    func deleteItineraryIfEmpty() async {
        // Only relevant if we're editing an existing itinerary
        if isEditing, let existingId = existingItineraryId, scheduledPlaces.isEmpty {
            await MainActor.run {
                self.isLoading = true
                self.error = nil
            }
            
            do {
                try await itineraryManager.deleteItinerary(tripId: tripId, day: day)
                
                await MainActor.run {
                    self.isSuccess = true
                    self.isLoading = false
                    self.existingItineraryId = nil
                    
                    // Update our allItineraries array too
                    self.allItineraries.removeAll(where: { $0.dayNumber == self.day })
                    
                    // Update our dictionary
                    self.scheduledPlacesByDay[self.day] = []
                }
            } catch {
                await MainActor.run {
                    self.error = "Failed to delete empty itinerary: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

// Input model for the form
class ScheduledPlaceInput: Identifiable, ObservableObject {
    let id = UUID()
    @Published var placeId: String? = nil
    @Published var startTime: Date? = nil
    @Published var endTime: Date? = nil
    @Published var notes: String? = nil
} 