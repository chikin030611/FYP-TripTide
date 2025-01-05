import SwiftUI
import CoreLocation
import MapKit

class AttractionDetailViewModel: ObservableObject {
    @Published var attraction: Attraction
    @Published var cameraPosition: MapCameraPosition
    @Published var isLoading = false
    @Published var error: Error?
    
    init(attractionId: String) {
        // Initialize with empty attraction first
        self.attraction = .empty
        self.cameraPosition = .camera(
            .init(
                centerCoordinate: CLLocationCoordinate2D(
                    latitude: 0,
                    longitude: 0
                ),
                distance: 2000
            )
        )
        
        // Fetch the actual data
        Task {
            await fetchAttractionDetail(id: attractionId)
        }
    }
    
    @MainActor
    private func fetchAttractionDetail(id: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let detail = try await PlacesAPIController.shared.fetchPlaceDetail(id: id)
            
            // Convert API response to Attraction model
            self.attraction = Attraction(
                id: detail.id,
                images: detail.photos.map { PlacesAPIController.shared.appendAPIKey(to: $0) },
                name: detail.name,
                rating: Float(detail.rating),
                price: "", // Add if available in API
                tags: detail.tags.compactMap { name in
                    guard !name.isEmpty else { return nil }
                    return Tag(name: name)
                },
                openHours: detail.openingHours.map { Array<OpenHour>.from($0) } ?? [],
                stayingTime: "1-2 hours", // Add if available in API
                description: detail.description ?? "No description available",
                address: detail.address,
                latitude: detail.latitude,
                longitude: detail.longitude
            )
            
            // Update camera position
            self.cameraPosition = .camera(
                .init(
                    centerCoordinate: CLLocationCoordinate2D(
                        latitude: detail.latitude,
                        longitude: detail.longitude
                    ),
                    distance: 2000
                )
            )
        } catch {
            self.error = error
        }
    }
    
    func toggleFavorite() {
        // Implement favorite toggle logic
    }
} 