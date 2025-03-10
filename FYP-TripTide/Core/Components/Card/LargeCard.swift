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
                // Add an id to force view refresh when isAdded changes
                .id("heart-button-\(isAdded)")
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
        // Listen for notifications about place being added/removed from trips
        // But filter them to only respond to notifications about THIS place
        .onReceive(NotificationCenter.default.publisher(for: .placeAddedToTrip)) { notification in
            // Get the trip ID from the notification
            if let tripId = notification.object as? String,
               // Get the userInfo dictionary (we'll need to add this to the notification)
               let userInfo = notification.userInfo as? [String: String],
               // Get the place ID from the userInfo
               let placeId = userInfo["placeId"],
               // Only proceed if this notification is about this place
               placeId == place.id {
                print("LargeCard - Received placeAddedToTrip notification for place: \(place.id)")
                Task {
                    await checkIfPlaceInAnyTrip()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .placeRemovedFromTrip)) { notification in
            // Get the trip ID from the notification
            if let tripId = notification.object as? String,
               // Get the userInfo dictionary
               let userInfo = notification.userInfo as? [String: String],
               // Get the place ID from the userInfo
               let placeId = userInfo["placeId"],
               // Only proceed if this notification is about this place
               placeId == place.id {
                print("LargeCard - Received placeRemovedFromTrip notification for place: \(place.id)")
                Task {
                    await checkIfPlaceInAnyTrip()
                }
            }
        }
    }
}
