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
    
    private let placesAPIController = PlacesAPIController.shared
    private let authManager = AuthManager.shared
    
    init() {
        Task {
            await checkAuthAndFetchRecommendations()
        }
    }
    
    func checkAuthAndFetchRecommendations() async {
        do {
            // Then fetch recommendations
            await fetchRecommendations()
        } catch {
            if case APIError.unauthorized = error {
                // Handle unauthorized error (e.g., redirect to login)
                isUserLoggedIn = false
            }
            self.error = error
            print("Error in auth check: \(error)")
        }
    }
    
    func fetchRecommendations() async {
        isLoading = true
        
        do {
            let recommendedPlaces = try await placesAPIController.fetchRecommendations()
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