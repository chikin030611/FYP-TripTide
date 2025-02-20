import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isUserLoggedIn = false
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var places: [Place] = []
    @Published var cards: [Card] = []
    
    init() {
        places = [
            Place(
                id: "1",
                images: ["https://picsum.photos/300/300"],
                name: "Central",
                type: "District",
                rating: 4.5,
                ratingCount: 100,
                price: "$",
                tags: [Tag(name: "Central")],
                openHours: [OpenHour(from: ["open": ["day": 1, "hour": 9, "minute": 0], "close": ["day": 1, "hour": 17, "minute": 0]])],
                stayingTime: "2 hours",
                description: "Central is a district in Hong Kong",
                address: "Central, Hong Kong",
                latitude: 22.2766,
                longitude: 114.1633
            ),
            Place(
                id: "2",
                images: ["https://picsum.photos/300/300"],
                name: "Central",
                type: "District",
                rating: 4.5,
                ratingCount: 100,
                price: "$",
                tags: [Tag(name: "Central")],
                openHours: [OpenHour(from: ["open": ["day": 1, "hour": 9, "minute": 0], "close": ["day": 1, "hour": 17, "minute": 0]])],
                stayingTime: "2 hours",
                description: "Central is a district in Hong Kong",
                address: "Central, Hong Kong",
                latitude: 22.2766,
                longitude: 114.1633
            )
        ]
        cards = places.map { Card(place: $0) }
    }
    
    // func setup() async {
    //     await checkUserLoginStatus()
    //     if isUserLoggedIn {
    //         await fetchUserProfile()
    //     }
    // }
    
    // func checkUserLoginStatus() async {
    //     await AuthManager.shared.validateToken()
    //     isUserLoggedIn = AuthManager.shared.isAuthenticated
    // }
    
    // func fetchUserProfile() async {
    //     isLoading = true
    //     error = nil
        
    //     do {
    //         user = try await AuthService.shared.getUserProfile()
    //     } catch {
    //         self.error = error
    //     }
    //     isLoading = false
    // }
}