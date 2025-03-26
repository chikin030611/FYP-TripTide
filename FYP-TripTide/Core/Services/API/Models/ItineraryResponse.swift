import Foundation

// Data structures for request
struct CreateItineraryRequest: Codable {
    let day: Int
    let scheduledPlaces: [ScheduledPlaceDto]
}

// For update endpoint
struct UpdateItineraryRequest: Codable {
    let scheduledPlaces: [ScheduledPlaceDto]
}

struct ScheduledPlaceDto: Codable {
    let placeId: String
    let startTime: String // Format: "HH:mm:ss"
    let endTime: String   // Format: "HH:mm:ss"
    let notes: String?
} 

// API response models - separate from domain models
struct APIScheduledPlace: Codable {
    let id: String
    let placeId: String
    let startTime: String // Format: "HH:mm:ss"
    let endTime: String   // Format: "HH:mm:ss"
    let notes: String?
    let date: Date?
    
    // Convert to domain model
    func toDomainModel() -> ScheduledPlace {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        // Safely handle start time
        var startDate: Date? = nil
        if !startTime.isEmpty && startTime != "00:00:00" {
            if let date = dateFormatter.date(from: startTime) {
                startDate = date
            } else {
                print("⚠️ APIScheduledPlace: Failed to parse start time: \(startTime)")
            }
        }
        
        // Safely handle end time
        var endDate: Date? = nil
        if !endTime.isEmpty && endTime != "00:00:00" {
            if let date = dateFormatter.date(from: endTime) {
                endDate = date
            } else {
                print("⚠️ APIScheduledPlace: Failed to parse end time: \(endTime)")
            }
        }
        
        return ScheduledPlace(
            id: id,
            placeId: placeId,
            startTime: startDate,
            endTime: endDate,
            notes: notes,
            date: date,
            photoUrl: nil
        )
    }
}

struct ItineraryResponse: Codable {
    let id: String
    let day: Int
    let date: Date
    let scheduledPlaces: [APIScheduledPlace]
    
    // Method to convert to your DailyItinerary model
    func toDailyItinerary(tripId: String) -> DailyItinerary {
        return DailyItinerary(
            id: self.id,
            tripId: tripId,
            dayNumber: self.day,
            date: self.date,
            places: self.scheduledPlaces.map { $0.toDomainModel() }
        )
    }
}