import Foundation
import Combine
import SwiftUI

class EditItineraryViewModel: ObservableObject {
    private let itineraryService = ItineraryService.shared
    private let placesService = PlacesService.shared
    private let tripId: String
    
    // Inputs
    @Published var day: Int {
        didSet {
            if oldValue != day {
                // Save current places for the old day
                scheduledPlacesByDay[oldValue] = scheduledPlaces
                
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
    
    init(tripId: String, day: Int, numberOfDays: Int, isEditing: Bool = false) {
        self.tripId = tripId
        self.day = day
        self.numberOfDays = numberOfDays
        self.isEditing = isEditing
        
        // Start loading places immediately
        Task { 
            await self.loadAvailablePlaces() 
            
            // If editing existing itinerary, fetch it
            if isEditing {
                await self.fetchExistingItinerary()
            }
        }
    }
    
    func fetchExistingItinerary() async {
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let dailyItinerary = try await itineraryService.fetchItinerary(tripId: tripId, day: day)
            
            await MainActor.run {
                self.existingItineraryId = dailyItinerary.id
                
                // Convert scheduled places to input model
                self.scheduledPlaces = dailyItinerary.places.map { place in
                    let input = ScheduledPlaceInput()
                    input.placeId = place.placeId
                    input.startTime = place.startTime
                    input.endTime = place.endTime
                    input.notes = place.notes
                    return input
                }
                
                // Save these places in our day dictionary
                self.scheduledPlacesByDay[self.day] = self.scheduledPlaces
                
                // If there are places, hide the drop area
                if !self.scheduledPlaces.isEmpty {
                    self.showDropArea = false
                }
                
                self.isLoading = false
            }
        } catch let apiError as APIError where apiError == .notFound {
            // If itinerary doesn't exist yet, that's ok for edit flow
            await MainActor.run {
                // Clear the places for this day and show drop area
                self.scheduledPlaces = []
                self.scheduledPlacesByDay[self.day] = []
                self.showDropArea = true
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load itinerary: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
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
        scheduledPlaces.append(ScheduledPlaceInput())
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
        }
    }
    
    func addPlaceWithId(_ placeId: String) {
        let newPlace = ScheduledPlaceInput()
        newPlace.placeId = placeId
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
                
                let startTime = place.startTime != nil ? formatter.string(from: place.startTime!) : "00:00:00"
                let endTime = place.endTime != nil ? formatter.string(from: place.endTime!) : "00:00:00"
                
                return ScheduledPlaceDto(
                    placeId: placeId,
                    startTime: startTime,
                    endTime: endTime,
                    notes: place.notes
                )
            }
            
            // Only proceed if we have at least one valid place
            if !dtos.isEmpty {
                let dailyItinerary: DailyItinerary
                
                if isEditing {
                    // Update existing itinerary
                    dailyItinerary = try await itineraryService.updateItinerary(
                        tripId: tripId,
                        day: day,
                        scheduledPlaces: dtos
                    )
                } else {
                    // Create new itinerary
                    dailyItinerary = try await itineraryService.createItinerary(
                        tripId: tripId, 
                        day: day,
                        scheduledPlaces: dtos
                    )
                }
                
                await MainActor.run {
                    self.isSuccess = true
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.error = "Please add at least one place with a valid ID"
                    self.isLoading = false
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
}

// Input model for the form
class ScheduledPlaceInput: Identifiable, ObservableObject {
    let id = UUID()
    @Published var placeId: String? = nil
    @Published var startTime: Date? = nil
    @Published var endTime: Date? = nil
    @Published var notes: String? = nil
} 