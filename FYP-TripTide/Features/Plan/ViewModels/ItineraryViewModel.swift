import Foundation
import Combine
import SwiftUI

class ItineraryViewModel: ObservableObject {
    private let itineraryManager = ItineraryManager.shared
    
    @Published var selectedDayIndex: Int = 0
    @Published var dailyItineraries: [DailyItinerary] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    
    let numberOfDays: Int
    let tripId: String
    
    init(tripId: String, numberOfDays: Int, initialItineraries: [DailyItinerary]? = nil) {
        self.tripId = tripId
        self.numberOfDays = numberOfDays
        
        if let itineraries = initialItineraries {
            self.dailyItineraries = itineraries
        }
        
        // Load itineraries if not provided
        if initialItineraries == nil {
            Task {
                await loadItineraries()
            }
        }
    }
    
    var selectedDayItinerary: DailyItinerary? {
        // Find the itinerary for the selected day by day number
        return dailyItineraries.first(where: { $0.dayNumber == selectedDayIndex + 1 })
    }
    
    func selectDay(index: Int) {
        selectedDayIndex = index
    }
    
    @MainActor
    func loadItineraries() async {
        self.isLoading = true
        self.error = nil
        
        do {
            let itineraries = try await itineraryManager.fetchAllItineraries(tripId: tripId)
            self.dailyItineraries = itineraries
            self.isLoading = false
        } catch {
            self.error = "Failed to load itineraries: \(error.localizedDescription)"
            self.isLoading = false
            print("❌ ItineraryViewModel: Error loading itineraries: \(error)")
        }
    }
    
    @MainActor
    func refreshItineraryData() async {
        self.isLoading = true
        self.error = nil
        
        do {
            print("🔄 ItineraryViewModel: Refreshing itinerary data for tripId: \(tripId)")
            
            // Force refresh from API
            let itineraries = try await itineraryManager.fetchAllItineraries(tripId: tripId, forceRefresh: true)
            self.dailyItineraries = itineraries
            print("✅ ItineraryViewModel: Successfully refreshed \(itineraries.count) itineraries")
            
            self.isLoading = false
        } catch {
            self.error = "Failed to refresh itineraries: \(error.localizedDescription)"
            self.isLoading = false
            print("❌ ItineraryViewModel: Failed to refresh itinerary data: \(error.localizedDescription)")
        }
    }
    
    // Helper method to get the itinerary for a specific day
    func getItineraryForDay(day: Int) -> DailyItinerary? {
        return dailyItineraries.first(where: { $0.dayNumber == day })
    }
}

class ScheduledPlaceViewModel: ObservableObject {
    private let placesService = PlacesService.shared
    private let scheduledPlace: ScheduledPlace
    
    @Published var placeName: String = "Loading..."
    @Published var placeImage: String = "placeholder"
    @Published var placeType: String = "Loading..."
    @Published var isLoading: Bool = true
    @Published var loadingError: String? = nil
    @Published var isPlaceLoaded: Bool = false
    
    init(scheduledPlace: ScheduledPlace) {
        self.scheduledPlace = scheduledPlace
    }
    
    var hasStartAndEndTime: Bool {
        return scheduledPlace.startTime != nil && scheduledPlace.endTime != nil
    }

    var date: Date? {
        return scheduledPlace.date
    }
    
    var startTime: Date? {
        return scheduledPlace.startTime
    }
    
    var endTime: Date? {
        return scheduledPlace.endTime
    }
    
    var notes: String? {
        return scheduledPlace.notes
    }
    
    func loadPlaceDetails() {
        // Don't reload if already loaded
        if isPlaceLoaded { return }
        
        Task {
            self.isLoading = true
            self.loadingError = nil
            
            do {
                // Try to fetch place basic data
                let placeData = try await placesService.fetchPlaceBasicById(
                    id: scheduledPlace.placeId)
                
                await MainActor.run {
                    self.placeName = placeData.name
                    self.placeType = placeData.type.formatTagName()
                    // Make sure photoUrl is not empty
                    if !placeData.photoUrl.isEmpty {
                        self.placeImage = placesService.appendAPIKey(to: placeData.photoUrl)
                    }
                    self.isLoading = false
                    self.isPlaceLoaded = true
                }
            } catch {
                await MainActor.run {
                    self.placeName = "Failed to load"
                    self.placeType = "Failed to load"
                    self.isLoading = false
                    self.loadingError = "Could not load place data"
                    print("Error loading place details: \(error)")
                }
            }
        }
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
} 