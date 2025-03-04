import Foundation

struct TripResponse: Codable {
    let id: String
    let name: String
    let description: String
    let startDate: Date
    let endDate: Date
    let touristAttractionIds: [String]
    let restaurantIds: [String]
    let lodgingIds: [String]
    let image: String
    let dailyItineraries: [DailyItinerary]
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
            endDate: endDate
        )
    }
}

struct UserResponse: Codable {
    let id: Int
    let username: String
    let email: String
}