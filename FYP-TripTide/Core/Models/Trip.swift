import Foundation

struct Trip: Identifiable {
    var id: String
    var name: String
    var description: String
    var touristAttractions: [Place]
    var restaurants: [Place]
    var lodgings: [Place]
    var startDate: Date
    var endDate: Date
    var image: String
    
    static let defaultImages = [
        "trip_default_1",
        "trip_default_2",
        "trip_default_3",
        "trip_default_4",
        "trip_default_5"
    ]

    var numOfDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    var savedCount: Int {
        touristAttractions.count + restaurants.count + lodgings.count
    }
    
    init(id: String = UUID().uuidString,
        name: String,
        description: String,
        touristAttractions: [Place] = [],
        restaurants: [Place] = [],
        lodgings: [Place] = [],
        startDate: Date,
        endDate: Date) {
        
        self.id = id
        self.name = name
        self.description = description
        self.touristAttractions = touristAttractions
        self.restaurants = restaurants
        self.lodgings = lodgings
        self.startDate = startDate
        self.endDate = endDate
        self.image = Trip.defaultImages.randomElement() ?? Trip.defaultImages[0]
    }
}

