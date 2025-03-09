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
            // Load tourist attractions
            let touristAttractions = try await PlacesService.shared.fetchPlacesByType(type: "tourist_attraction", limit: 5)
            let touristAttractionCards = touristAttractions.map { $0.toPlace() }
            self.highlyRatedCards = touristAttractionCards.map { Card(place: $0) }

            // Load restaurants
            let restaurants = try await PlacesService.shared.fetchPlacesByType(type: "restaurant", limit: 5)
            let restaurantCards = restaurants.map { $0.toPlace() }
            self.restaurantCards = restaurantCards.map { Card(place: $0) }
            
            // Load lodgings with better error handling
            do {
                let lodgings = try await PlacesService.shared.fetchPlacesByType(type: "lodging", limit: 5)
                if lodgings.isEmpty {
                    print("Warning: Received empty lodgings array from API")
                }
                let lodgingCards = lodgings.map { $0.toPlace() }
                await MainActor.run {
                    self.lodgingCards = lodgingCards.map { Card(place: $0) }
                }
            } catch {
                print("Error loading lodgings: \(error)")
                // Don't set hasLoadedData to true if lodgings failed
                throw error
            }
            
            // Set the flag to true after successful data load
            hasLoadedData = true
        } catch {
            print("Error in loadData: \(error)")
            self.error = error
            // Reset hasLoadedData on error so we can retry
            hasLoadedData = false
        }
    }
    
    // Add a method to check if sections are loaded
    func areSectionsLoaded() -> Bool {
        return !highlyRatedCards.isEmpty && !restaurantCards.isEmpty && !lodgingCards.isEmpty
    }
    
    // Add a method to force refresh data if needed
    func refreshData() async {
        hasLoadedData = false
        await loadData()
    }
} 