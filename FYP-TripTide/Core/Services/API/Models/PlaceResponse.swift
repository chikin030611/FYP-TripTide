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
