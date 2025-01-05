import Foundation

extension PlaceBasicData {
    func toAttraction() -> Attraction {
        let photoUrlWithKey = "\(photoUrl)\(APIConfig.googleMapsAPIKey)"
        return Attraction(
            id: placeId,
            images: [photoUrlWithKey],
            name: name,
            rating: Float(rating),
            price: "",
            tags: tags.map { Tag(name: $0) },
            openHours: [],
            stayingTime: "",
            description: "",
            address: "",
            latitude: 0,
            longitude: 0
        )
    }
} 