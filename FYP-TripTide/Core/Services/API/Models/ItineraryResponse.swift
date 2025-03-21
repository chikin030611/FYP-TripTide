import Foundation

// Data structures for request
struct CreateItineraryRequest: Codable {
    let day: Int
    let scheduledPlaces: [ScheduledPlaceDto]
}

struct ScheduledPlaceDto: Codable {
    let placeId: String
    let startTime: String // Format: "HH:mm:ss"
    let endTime: String   // Format: "HH:mm:ss"
    let notes: String?
} 

// Add this to your ItineraryService.swift file
struct ItineraryResponse: Codable {
    let id: String
    let day: Int
    let date: Date
    let scheduledPlaces: [ScheduledPlace]
    
    // Method to convert to your DailyItinerary model
    func toDailyItinerary(tripId: String) -> DailyItinerary {
        return DailyItinerary(
            id: self.id,
            tripId: tripId, // Use the tripId from the request
            dayNumber: self.day,
            date: self.date,
            places: self.scheduledPlaces
        )
    }
}