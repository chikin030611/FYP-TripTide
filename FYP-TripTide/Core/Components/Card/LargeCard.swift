import SwiftUI

struct LargeCard: View {
    let place: Place
    @State private var isAdded: Bool = false
    @State private var isAnimating: Bool = false
    @State private var showAddToTripSheet = false
    @StateObject var themeManager = ThemeManager()
    @StateObject private var tripsManager = TripsManager.shared

    init(place: Place) {
        self.place = place
    }
    
    // Check if the place is in any trip using the new helper method
    private func checkIfPlaceInAnyTrip() async {
        isAdded = await tripsManager.isPlaceInAnyTrip(placeId: place.id)
    }

    var body: some View {
        NavigationLink(destination: PlaceDetailView(place: place)) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 2) {
                    AsyncImageView(imageUrl: place.images[0], width: 220, height: 180)

                    Text(place.type.formatTagName())
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundColor(themeManager.selectedTheme.bgTextColor)
                        .padding(.horizontal, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(themeManager.selectedTheme.accentColor)
                        )

                    Text(place.name)
                        .font(themeManager.selectedTheme.boldBodyTextFont)
                        .foregroundColor(themeManager.selectedTheme.primaryColor)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Rating(rating: place.rating, ratingCount: place.ratingCount)

                    TagGroup(tags: place.tags)
                }
                .frame(width: 220, alignment: .leading)

                Button(action: {
                    // Start the scale animation
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isAnimating = true
                    }
                    // Reset the scale after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isAnimating = false
                        }
                    }
                    showAddToTripSheet = true
                }) {
                    Text(isAdded ? "Remove" : "Add")
                }
                .buttonStyle(HeartToggleButtonStyle(isAdded: isAdded))
                .padding(12)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
            }
        }
        .sheet(isPresented: $showAddToTripSheet) {
            AddToTripSheet(
                place: place,
                onAddPlaceToTrip: { place, trip in
                    isAdded = true  // Update the button state when a place is added
                },
                onRemovePlaceFromTrip: { place, trip in
                    // Check if the place is still in any trip after removal
                    Task {
                        await checkIfPlaceInAnyTrip()
                    }
                }
            )
        }
        .task {
            await checkIfPlaceInAnyTrip()
        }
    }
}
