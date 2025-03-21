import Foundation
import Combine
import SwiftUI

class CreateItineraryViewModel: ObservableObject {
    private let itineraryService = ItineraryService.shared
    private let placesService = PlacesService.shared
    private let tripId: String
    
    // Inputs
    @Published var day: Int
    @Published var numberOfDays: Int
    @Published var scheduledPlaces: [ScheduledPlaceInput] = []
    
    // Status
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var isSuccess = false
    
    // Available places
    @Published var availablePlaces: [Place] = []
    @Published var touristAttractions: [Place] = []
    @Published var restaurants: [Place] = []
    @Published var lodgings: [Place] = []
    @Published var isLoadingPlaces = false
    
    init(tripId: String, day: Int, numberOfDays: Int) {
        self.tripId = tripId
        self.day = day
        self.numberOfDays = numberOfDays
        
        // Add one empty scheduled place to start with
        self.scheduledPlaces.append(ScheduledPlaceInput())
    }
    
    func loadAvailablePlaces() {
        Task {
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
    }

    func addPlace() {
        scheduledPlaces.append(ScheduledPlaceInput())
    }
    
    func removePlaceAt(index: Int) {
        guard index < scheduledPlaces.count else { return }
        scheduledPlaces.remove(at: index)
    }
    
    func saveItinerary() async {
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let dtos = scheduledPlaces.compactMap { place -> ScheduledPlaceDto? in
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
                let dailyItinerary = try await itineraryService.createItinerary(
                    tripId: tripId, 
                    day: day,
                    scheduledPlaces: dtos
                )
                
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