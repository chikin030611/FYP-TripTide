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

extension PlaceDetailResponse {
    func toAttraction() -> Attraction {
        // Convert photos to full URLs with API key
        let photoUrlsWithKey = photos.map { "\($0)\(APIConfig.googleMapsAPIKey)" }
        
        // Convert tags to Tag objects
        let tagObjects = tags.map { Tag(name: $0) }
        
        // Convert opening hours using the existing extension
        let openHours = openingHours.map { [OpenHour].from($0) } ?? []
        
        return Attraction(
            id: id,
            images: photoUrlsWithKey,
            name: name,
            rating: Float(rating),
            price: "",
            tags: tagObjects,
            openHours: openHours,
            stayingTime: "",
            description: description ?? "",
            address: address,
            latitude: latitude,
            longitude: longitude
        )
    }
} 