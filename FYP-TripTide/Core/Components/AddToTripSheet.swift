import SwiftUI

// Create a separate view for the trip list
private struct TripListView: View {
    let trips: [Trip]
    let place: Place
    let onAddPlaceToTrip: ((Place, Trip) -> Void)?
    let onError: (String) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(trips) { trip in
                    AddToTripCard(trip: trip, place: place) { selectedTrip, wasAdded in
                        if wasAdded {
                            onAddPlaceToTrip?(place, selectedTrip)
                        }
                        onDismiss()
                    }
                    .padding(.horizontal, 3)
                }
            }
            .padding(.bottom, 30)
            .padding(.horizontal, 10)
        }
    }
}

// Main AddToTripSheet view
struct AddToTripSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var tripsManager = TripsManager.shared
    
    let place: Place
    @State private var error: String?
    
    var onAddPlaceToTrip: ((Place, Trip) -> Void)?
    
    private var content: some View {
        Group {
            if tripsManager.isLoading {
                ProgressView()
            } else if tripsManager.trips.isEmpty {
                Text("No trips available. Create a trip first!")
                    .foregroundColor(.gray)
            } else {
                TripListView(
                    trips: tripsManager.trips,
                    place: place,
                    onAddPlaceToTrip: onAddPlaceToTrip,
                    onError: { self.error = $0 },
                    onDismiss: { dismiss() }
                )
            }
        }
    }
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("Add to Trip")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button("Done") {
                    dismiss()
                })
                .alert("Error", isPresented: Binding(
                    get: { error != nil },
                    set: { if !$0 { error = nil } }
                )) {
                    Button("OK") { error = nil }
                } message: {
                    Text(error ?? "Unknown error")
                }
        }
        .presentationDetents([.height(300)])
        .accentColor(themeManager.selectedTheme.accentColor)
        .task {
            await tripsManager.fetchTrips()
        }
    }
}