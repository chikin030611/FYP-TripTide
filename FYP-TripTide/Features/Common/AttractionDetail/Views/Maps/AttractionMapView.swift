import SwiftUI
import MapKit

struct AttractionMapView: View {
    let attraction: Attraction
    @Environment(\.dismiss) private var dismiss
    @State private var cameraPosition: MapCameraPosition
    
    init(attraction: Attraction) {
        self.attraction = attraction
        let coordinate = CLLocationCoordinate2D(
            latitude: attraction.latitude,
            longitude: attraction.longitude
        )
        _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )))
    }
    
    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                Marker(attraction.name, coordinate: CLLocationCoordinate2D(
                    latitude: attraction.latitude,
                    longitude: attraction.longitude
                ))
            }
            .navigationTitle(attraction.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
} 