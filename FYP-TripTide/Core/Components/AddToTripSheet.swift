import SwiftUI

// Create a separate view for the trip list
private struct TripListView: View {
    let trips: [Trip]
    let place: Place
    let onAddPlaceToTrip: ((Place, Trip) -> Void)?
    let onRemovePlaceFromTrip: ((Place, Trip) -> Void)?
    let onError: (String) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(trips) { trip in
                    AddToTripCard(trip: trip, place: place) { selectedTrip, wasAdded in
                        if wasAdded {
                            onAddPlaceToTrip?(place, selectedTrip)
                        } else {
                            onRemovePlaceFromTrip?(place, selectedTrip)
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
    @ObservedObject private var tripsManager = TripsManager.shared
    
    let place: Place
    @State private var error: String?
    @State private var isInitialLoading: Bool = true
    
    var onAddPlaceToTrip: ((Place, Trip) -> Void)?
    var onRemovePlaceFromTrip: ((Place, Trip) -> Void)?
    
    private var content: some View {
        Group {
            if isInitialLoading {
                VStack {
                    ProgressView("Loading trips...")
                    Text("This may take a moment")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            } else if tripsManager.isLoading && tripsManager.trips.isEmpty {
                ProgressView("Loading trips...")
            } else if tripsManager.trips.isEmpty {
                Text("No trips available. Create a trip first!")
                    .foregroundColor(.gray)
            } else {
                TripListView(
                    trips: tripsManager.trips,
                    place: place,
                    onAddPlaceToTrip: onAddPlaceToTrip,
                    onRemovePlaceFromTrip: onRemovePlaceFromTrip,
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
        .onAppear {
            print("🔍 AddToTripSheet appeared - trips count: \(tripsManager.trips.count), isLoading: \(tripsManager.isLoading)")
            // Check if we already have trips loaded
            if !tripsManager.trips.isEmpty && !tripsManager.isLoading {
                isInitialLoading = false
                print("✅ Using existing trips data - skipping initial loading state")
            }
        }
        .task {
            // If trips are already loading, wait for them to finish
            if tripsManager.isLoading {
                print("⏳ Trips already loading, waiting...")
            }
            
            print("🌐 AddToTripSheet task started - Will fetch trips")
            let startTime = Date()
            
            // Try to use cached trips first with forceRefresh = false
            await tripsManager.fetchTrips(forceRefresh: false)
            
            // Regardless of whether we used cache or not, hide the loading screen
            isInitialLoading = false
            
            print("⏱️ AddToTripSheet fetch completed in \(Date().timeIntervalSince(startTime)) seconds")
            print("📋 After fetch - trips count: \(tripsManager.trips.count)")
        }
    }
}