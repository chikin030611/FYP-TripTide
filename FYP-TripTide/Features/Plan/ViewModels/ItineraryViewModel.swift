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

