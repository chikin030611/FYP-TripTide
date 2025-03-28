import Foundation

struct PlaceBasicData: Codable {
    let placeId: String
    let name: String
    let type: String
    let tags: [String]
    let photoUrl: String
    let rating: Double?
    let ratingCount: String
}

struct PlaceDetailResponse: Codable {
    let id: String
    let name: String
    let type: String
    let tags: [String]
    let address: String
    let rating: Double?
    let ratingCount: String
    let openingHours: OpeningHours?
    let description: String?
    let photos: [String]
    let latitude: Double
    let longitude: Double
    
    struct OpeningHours: Codable {
        let periods: [Period]
        
        struct Period: Codable {
            let open: TimeInfo
            let close: TimeInfo
            
            struct TimeInfo: Codable {
                let day: Int
                let hour: Int
                let minute: Int
                let date: DateInfo
                
                struct DateInfo: Codable {
                    let year: Int
                    let month: Int
                    let day: Int
                }
            }
        }
    }
} 

struct RecommendationsResponse: Codable {
    let recommendations: [PlaceBasicData]
    
    // If the API returns recommendations under a different key, change "recommendations" to match
    private enum CodingKeys: String, CodingKey {
        case recommendations = "recommendations" // Change this if needed
    }
}

// Place Mapper
extension PlaceBasicData {
    func toPlace() -> Place {
        let photoUrlWithKey = "\(photoUrl)\(APIConfig.googleMapsAPIKey)"
        return Place(
            id: placeId,
            images: [photoUrlWithKey],
            name: name,
            type: type,
            rating: rating != nil ? Float(rating!) : nil,
            ratingCount: Int(ratingCount) ?? 0,
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
    func toPlace() -> Place {
        // Convert photos to full URLs with API key
        let photoUrlsWithKey = photos.map { "\($0)\(APIConfig.googleMapsAPIKey)" }
        
        // Convert tags to Tag objects
        let tagObjects = tags.map { Tag(name: $0) }
        
        // Convert opening hours using the existing extension
        let openHours = openingHours.map { [OpenHour].from($0) } ?? []
        
        return Place(
            id: id,
            images: photoUrlsWithKey,
            name: name,
            type: "",
            rating: rating != nil ? Float(rating!) : nil,
            ratingCount: 0,
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