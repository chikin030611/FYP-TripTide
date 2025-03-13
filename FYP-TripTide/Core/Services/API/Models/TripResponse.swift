import Foundation

struct TripResponse: Codable {
    let id: String
    let name: String
    let description: String
    let image: String
    let startDate: Date
    let endDate: Date
    let touristAttractionIds: [String]
    let restaurantIds: [String]
    let lodgingIds: [String]
    let dailyItineraries: [DailyItineraryResponse]?
    
    func toTrip() -> Trip {
        Trip(
            id: id,
            userId: "",
            name: name,
            description: description,
            touristAttractionsIds: touristAttractionIds,
            restaurantsIds: restaurantIds,
            lodgingsIds: lodgingIds,
            startDate: startDate,
            endDate: endDate,
            image: image,
            dailyItineraries: dailyItineraries?.map { $0.toDailyItinerary(tripId: id) }
        )
    }
}

// Response model for DailyItinerary
struct DailyItineraryResponse: Codable {
    let id: String
    let day: Int
    let scheduledPlaces: [ScheduledPlaceResponse]?
    
    func toDailyItinerary(tripId: String) -> DailyItinerary {
        DailyItinerary(
            id: id,
            tripId: tripId,
            dayNumber: day,
            places: scheduledPlaces?.map { $0.toScheduledPlace() } ?? []
        )
    }
}

// Response model for ScheduledPlace
struct ScheduledPlaceResponse: Codable {
    let id: String
    let placeId: String
    let startTime: String
    let endTime: String
    let notes: String?
    
    func toScheduledPlace() -> ScheduledPlace {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        
        // Create base date to combine with time
        let calendar = Calendar.current
        let now = Date()
        let baseDate = calendar.startOfDay(for: now)
        
        // Parse time strings to Date objects
        var startDate: Date? = nil
        if let timeDate = formatter.date(from: startTime) {
            startDate = calendar.date(bySettingHour: calendar.component(.hour, from: timeDate),
                                     minute: calendar.component(.minute, from: timeDate),
                                     second: calendar.component(.second, from: timeDate),
                                     of: baseDate)
        }
        
        var endDate: Date? = nil
        if let timeDate = formatter.date(from: endTime) {
            endDate = calendar.date(bySettingHour: calendar.component(.hour, from: timeDate),
                                   minute: calendar.component(.minute, from: timeDate),
                                   second: calendar.component(.second, from: timeDate),
                                   of: baseDate)
        }
        
        return ScheduledPlace(
            id: id,
            placeId: placeId,
            startTime: startDate,
            endTime: endDate,
            notes: notes
        )
    }
}

struct UserResponse: Codable {
    let id: Int
    let username: String
    let email: String
}

struct UpdateTripRequest: Codable {
    let name: String
    let description: String
    let startDate: Int64
    let endDate: Int64
    
    init(name: String, description: String, startDate: Date, endDate: Date) {
        self.name = name
        self.description = description
        self.startDate = Int64(startDate.timeIntervalSince1970 * 1000)
        self.endDate = Int64(endDate.timeIntervalSince1970 * 1000)
    }
} 

struct CreateTripRequest: Codable {
    let name: String
    let description: String
    let startDate: Int64
    let endDate: Int64
    let image: String

    init(name: String, description: String, startDate: Date, endDate: Date, image: String) {
        self.name = name
        self.description = description
        self.startDate = Int64(startDate.timeIntervalSince1970 * 1000)
        self.endDate = Int64(endDate.timeIntervalSince1970 * 1000)
        self.image = image
    }
}
