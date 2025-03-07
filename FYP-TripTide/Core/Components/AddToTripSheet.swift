import SwiftUI

struct AddToTripSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager()
    
    let place: Place  // Add the place parameter
    var trips: [Trip] = [Trip.sampleTrip, Trip.sampleTrip, Trip.sampleTrip]
    @State private var navigationPath = NavigationPath()
    
    // Callback for when a place is added to a trip
    var onAddPlaceToTrip: ((Place, Trip) -> Void)?
    
    var body: some View {
        NavigationView {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(trips) { trip in
                        AddToTripCard(trip: trip) { selectedTrip in
                            print("Adding place '\(place.name)' to trip '\(selectedTrip.name)'")
                            onAddPlaceToTrip?(place, selectedTrip)
                            dismiss()
                        }
                        .padding(.horizontal, 3)
                    }
                }
                .padding(.bottom, 30)
                .padding(.horizontal, 10)
            }
            .navigationTitle("Add to Trip")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
        .presentationDetents([.height(300)])
        .accentColor(themeManager.selectedTheme.accentColor)
    }
}