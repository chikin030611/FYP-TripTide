import SwiftUI

@MainActor
class SearchTabViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var highlyRatedCards: [Card] = []
    @Published var restaurantCards: [Card] = []
    @Published var lodgingCards: [Card] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    // MARK: - Constants
    let logoIcon = "airplane.departure"
    
    let highlyRatedSection = (
        icon: "sparkles",
        title: NSLocalizedString("Highly Rated Attractions", comment: "Title of the For You section")
    )
    
    let restaurantSection = (
        icon: "fork.knife",
        title: NSLocalizedString("Restaurant", comment: "Title of the restaurant section")
    )
    
    let lodgingSection = (
        icon: "bed.double.fill",
        title: NSLocalizedString("Lodging", comment: "Title of the lodging section")
    )
    
    // MARK: - Initialization
    init() {
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch tourist attractions
            let places = try await PlacesAPIController.shared.fetchPlaces(type: "tourist_attraction", limit: 5)
            let attractions = places.map { $0.toAttraction() }
            print("Attractions: \(attractions)")
            // Update the cards
            self.highlyRatedCards = attractions.map { Card(attraction: $0) }
            
            
            // Similarly fetch and update restaurant and lodging cards
            // You might want to adjust the API calls for different types
            
        } catch {
            self.error = error
        }
    }
} 