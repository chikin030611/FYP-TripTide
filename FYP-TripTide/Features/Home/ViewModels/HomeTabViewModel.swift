import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isUserLoggedIn = false
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var places: [Place] = []
    @Published var cards: [Card] = []
    @Published var recommendations: [Card] = []
    
    private let placesService = PlacesService.shared
    private let authManager = AuthManager.shared
    
    init() {
        Task {
            await checkAuthAndFetchRecommendations()
        }
    }
    
    func checkAuthAndFetchRecommendations() async {
        await fetchRecommendations()
    }
    
    func fetchRecommendations() async {
        isLoading = true
        
        do {
            let recommendedPlaces = try await placesService.fetchRecommendations()
            self.places = recommendedPlaces.map { placeData in
                placeData.toPlace()
            }
            // Create cards from places
            self.cards = self.places.map { Card(place: $0) }
        } catch {
            self.error = error
            print("Error fetching recommendations: \(error)")
            
            if case APIError.unauthorized = error {
                isUserLoggedIn = false
            }
        }
        
        isLoading = false
    }
}