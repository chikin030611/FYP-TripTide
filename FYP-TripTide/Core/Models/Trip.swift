import Foundation

struct Trip: Identifiable {
    var id: String
    var userId: String
    var name: String
    var description: String
    var touristAttractionsIds: [String]
    var restaurantsIds: [String]
    var lodgingsIds: [String]
    var startDate: Date
    var endDate: Date
    var image: String

    var dailyItineraries: [DailyItinerary]?
    
    static let defaultImages = [
        "trip_default_1",
        "trip_default_2",
        "trip_default_3",
        "trip_default_4",
        "trip_default_5"
    ]

    var numOfDays: Int {
        (Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0) + 1
    }
    
    var savedCount: Int {
        touristAttractionsIds.count + restaurantsIds.count + lodgingsIds.count
    }
    
    init(id: String = UUID().uuidString,
        userId: String,
        name: String,
        description: String,
        touristAttractionsIds: [String] = [],
        restaurantsIds: [String] = [],
        lodgingsIds: [String] = [],
        startDate: Date,
        endDate: Date,
        image: String? = nil) {
        
        self.id = id
        self.userId = userId
        self.name = name
        self.description = description
        self.touristAttractionsIds = touristAttractionsIds
        self.restaurantsIds = restaurantsIds
        self.lodgingsIds = lodgingsIds
        self.startDate = startDate
        self.endDate = endDate
        self.image = image ?? Trip.defaultImages.randomElement() ?? Trip.defaultImages[0]
        self.dailyItineraries = []
    }
}

extension Trip {
    func printTrip() {
        print("\n\n\n=======================")
        print("Trip: \(name)")
        print("Description: \(description)")
        print("Start Date: \(startDate)")
        print("End Date: \(endDate)")
        print("Tourist Attractions: \(touristAttractionsIds)")
        print("Restaurants: \(restaurantsIds)")
        print("Lodgings: \(lodgingsIds)")
        print("Image: \(image)")
    }
}
