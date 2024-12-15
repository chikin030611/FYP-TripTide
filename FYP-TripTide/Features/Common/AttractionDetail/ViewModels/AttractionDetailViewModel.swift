import SwiftUI
import CoreLocation
import MapKit

class AttractionDetailViewModel: ObservableObject {
    @Published var attraction: Attraction
    @Published var cameraPosition: MapCameraPosition
    
    init(attractionId: String) {
        let attraction = getAttraction(by: attractionId) ?? .empty
        self.attraction = attraction
        self.cameraPosition = .camera(
            .init(
                centerCoordinate: CLLocationCoordinate2D(
                    latitude: attraction.latitude,
                    longitude: attraction.longitude
                ),
                distance: 2000
            )
        )
    }
    
    // MARK: - View Helper Methods
    
    var rating: Int {
        attraction.rating
    }
    
    // Add favorite functionality later
    func toggleFavorite() {
        // Implement favorite toggle logic
    }
} 