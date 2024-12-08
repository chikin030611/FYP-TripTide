import SwiftUI

class ExploreTabViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var forYouCards: [Card]
    @Published var restaurantCards: [Card]
    @Published var accommodationCards: [Card]
    
    // MARK: - Constants
    let logoIcon = "airplane.departure"
    
    let forYouSection = (
        icon: "sparkles",
        title: NSLocalizedString("For You", comment: "Title of the For You section"),
        description: NSLocalizedString("Discover attractions that are perfect for you", comment: "Description of the For You section")
    )
    
    let restaurantSection = (
        icon: "fork.knife",
        title: NSLocalizedString("Restaurant", comment: "Title of the restaurant section"),
        description: NSLocalizedString("Locals' favourite dining attractions", comment: "Description of the restaurant section")
    )
    
    let accommodationSection = (
        icon: "bed.double.fill",
        title: NSLocalizedString("Accommodation", comment: "Title of the accommodation section"),
        description: NSLocalizedString("Cozy attractions to stay", comment: "Description of the accommodation section")
    )
    
    // MARK: - Initialization
    init() {
        self.forYouCards = [
            Card(attractionId: "1"),
            Card(attractionId: "2"),
            Card(attractionId: "3")
        ]
        
        self.restaurantCards = [
            Card(attractionId: "4"),
            Card(attractionId: "5"),
            Card(attractionId: "6"),
            Card(attractionId: "7")
        ]
        
        self.accommodationCards = [
            Card(attractionId: "8"),
            Card(attractionId: "9"),
            Card(attractionId: "10")
        ]
    }
} 