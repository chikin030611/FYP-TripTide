import SwiftUI

class ExploreTabViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var highlyRatedCards: [Card]
    @Published var restaurantCards: [Card]
    @Published var accommodationCards: [Card]
    
    // MARK: - Constants
    let logoIcon = "airplane.departure"
    
    let highlyRatedSection = (
        icon: "star.fill",
        title: NSLocalizedString("Highly Rated Attractions", comment: "Title of the For You section")
    )
    
    let restaurantSection = (
        icon: "fork.knife",
        title: NSLocalizedString("Restaurant", comment: "Title of the restaurant section")
    )
    
    let accommodationSection = (
        icon: "bed.double.fill",
        title: NSLocalizedString("Accommodation", comment: "Title of the accommodation section")
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
        
        self.accommodationCards = [
            Card(attractionId: "8"),
            Card(attractionId: "9"),
            Card(attractionId: "10")
        ]
    }
} 