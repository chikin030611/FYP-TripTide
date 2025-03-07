import SwiftUI

@MainActor
class SearchTabViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var highlyRatedCards: [Card] = []
    @Published var restaurantCards: [Card] = []
    @Published var lodgingCards: [Card] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    // Add a flag to track if data has been loaded
    private var hasLoadedData = false
    
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
        // Check if data is already loaded
        if hasLoadedData { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let touristAttractions = try await PlacesService.shared.fetchPlacesByType(type: "tourist_attraction", limit: 5)
            let touristAttractionCards = touristAttractions.map { $0.toPlace() }
            self.highlyRatedCards = touristAttractionCards.map { Card(place: $0) }

            let restaurants = try await PlacesService.shared.fetchPlacesByType(type: "restaurant", limit: 5)
            let restaurantCards = restaurants.map { $0.toPlace() }
            self.restaurantCards = restaurantCards.map { Card(place: $0) }
            
            let lodgings = try await PlacesService.shared.fetchPlacesByType(type: "lodging", limit: 5)
            print("Lodgings: \(lodgings)")
            let lodgingCards = lodgings.map { $0.toPlace() }
            self.lodgingCards = lodgingCards.map { Card(place: $0) }
            
            // Set the flag to true after successful data load
            hasLoadedData = true
        } catch {
            self.error = error
        }
    }
    
    // Add a method to force refresh data if needed
    func refreshData() async {
        hasLoadedData = false
        await loadData()
    }
} 