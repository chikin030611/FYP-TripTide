import SwiftUI

class SearchTabViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var highlyRatedCards: [Card]
    @Published var restaurantCards: [Card]
    @Published var lodgingCards: [Card]
    
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
        self.highlyRatedCards = [
            Card(attractionId: "8"),
            Card(attractionId: "2"),
            Card(attractionId: "3")
        ]
        
        self.restaurantCards = [
            Card(attractionId: "4"),
            Card(attractionId: "5"),
            Card(attractionId: "6"),
            Card(attractionId: "7")
        ]
        
        self.lodgingCards = [
            Card(attractionId: "8"),
            Card(attractionId: "9"),
            Card(attractionId: "10")
        ]
    }
} 