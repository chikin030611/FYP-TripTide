import SwiftUI
import CoreLocation
import MapKit

class PlaceDetailViewModel: ObservableObject {
    @Published var place: Place
    @Published var cameraPosition: MapCameraPosition
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isInTrip = false

    @StateObject private var tripsManager = TripsManager.shared
    
    init(placeId: String) {
        // Initialize with empty place first
        self.place = .empty
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
            await fetchPlaceDetailById(id: placeId)
            await checkIfPlaceInAnyTrip(placeId: placeId)
        }
    }
    
    @MainActor
    private func fetchPlaceDetailById(id: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let detail = try await PlacesService.shared.fetchPlaceDetailById(id: id)
            
            // Convert API response to Place model
            self.place = Place(
                id: detail.id,
                images: detail.photos.map { PlacesService.shared.appendAPIKey(to: $0) },
                name: detail.name,
                type: detail.type,
                rating: Float(detail.rating ?? 0),
                ratingCount: Int(detail.ratingCount) ?? 0,
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

    
    // Check if the place is in any trip
    func checkIfPlaceInAnyTrip(placeId: String) async {
        let status = await TripsManager.shared.isPlaceInAnyTrip(placeId: placeId)
        await MainActor.run {
            print("PlaceDetailView - Place \(placeId) in trip status: \(status)")
            self.isInTrip = status
        }
    }
} 
