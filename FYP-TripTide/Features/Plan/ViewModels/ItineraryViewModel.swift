import Foundation
import Combine
import SwiftUI

class ItineraryViewModel: ObservableObject {
    @Published var selectedDayIndex: Int = 0
    let dailyItineraries: [DailyItinerary]?
    let numberOfDays: Int
    
    init(dailyItineraries: [DailyItinerary]?, numberOfDays: Int) {
        self.dailyItineraries = dailyItineraries
        self.numberOfDays = numberOfDays
    }
    
    var selectedDayItinerary: DailyItinerary? {
        guard let itineraries = dailyItineraries,
              selectedDayIndex < itineraries.count else {
            return nil
        }
        return itineraries[selectedDayIndex]
    }
    
    func selectDay(index: Int) {
        selectedDayIndex = index
    }
}

class ScheduledPlaceViewModel: ObservableObject {
    private let placesService = PlacesService.shared
    private let scheduledPlace: ScheduledPlace
    
    @Published var placeName: String = "Loading..."
    @Published var placeImage: String = "placeholder"
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