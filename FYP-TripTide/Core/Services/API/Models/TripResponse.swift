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
    let dailyItineraries: [DailyItinerary]?
    let user: UserResponse
    
    func toTrip() -> Trip {
        Trip(
            id: id,
            userId: String(user.id),
            name: name,
            description: description,
            touristAttractionsIds: touristAttractionIds,
            restaurantsIds: restaurantIds,
            lodgingsIds: lodgingIds,
            startDate: startDate,
            endDate: endDate,
            image: image
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