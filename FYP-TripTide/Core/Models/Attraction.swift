import Foundation

struct Attraction: Identifiable {
    var id: String
    var images: [String]
    var name: String
    var rating: Int
    var price: String
    var tags: [Tag]
    var openHours: [OpenHour]
    var stayingTime: String
    var description: String
    var address: String
    var latitude: Double
    var longitude: Double
}

extension Attraction {
    static let empty = Attraction(
        id: "",
        images: [],
        name: "",
        rating: 0,
        price: "",
        tags: [],
        openHours: [],
        stayingTime: "",
        description: "",
        address: "",
        latitude: 0,
        longitude: 0
    )
} 