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
    init() { }
    
    func loadData() async {
        if !highlyRatedCards.isEmpty { return }  // Skip if already loaded
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let touristAttractions = try await PlacesAPIController.shared.fetchPlaces(type: "tourist_attraction", limit: 5)
            let touristAttractionCards = touristAttractions.map { $0.toPlace() }
            self.highlyRatedCards = touristAttractionCards.map { Card(place: $0) }

            let restaurants = try await PlacesAPIController.shared.fetchPlaces(type: "restaurant", limit: 5)
            let restaurantCards = restaurants.map { $0.toPlace() }
            self.restaurantCards = restaurantCards.map { Card(place: $0) }
            
            let lodgings = try await PlacesAPIController.shared.fetchPlaces(type: "lodging", limit: 5)
            let lodgingCards = lodgings.map { $0.toPlace() }
            self.lodgingCards = lodgingCards.map { Card(place: $0) }
        } catch {
            self.error = error
        }
    }
} 