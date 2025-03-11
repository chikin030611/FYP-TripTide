import Foundation

struct Place: Identifiable {
    var id: String
    var images: [String]
    var name: String
    var type: String
    var rating: Float?
    var ratingCount: Int
    var price: String
    var tags: [Tag]
    var openHours: [OpenHour]
    var stayingTime: String
    var description: String
    var address: String
    var latitude: Double
    var longitude: Double
}

extension Place {
    static let empty = Place(
        id: "",
        images: [],
        name: "",
        type: "",
        rating: nil,
        ratingCount: 0,
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

extension Place: Equatable {
    static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.id == rhs.id
    }
}