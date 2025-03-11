import SwiftUI

struct WideCard: View {

    @StateObject var themeManager = ThemeManager()
    @State private var isAdded: Bool = false
    @State private var isAnimating: Bool = false
    @State private var showAddToTripSheet = false
    @StateObject private var tripsManager = TripsManager.shared

    let place: Place

    init(place: Place) {
        self.place = place
    }
    
    // Function to check place status and update isAdded
    private func checkPlaceStatus() {
        Task {
            // Force UI update by dispatching to main thread
            let status = await tripsManager.isPlaceInAnyTrip(placeId: place.id)
            await MainActor.run {
                print("WideCard - Place \(place.id) in trip status: \(status)")
                self.isAdded = status
            }
        }
    }

    var body: some View {
        NavigationLink(destination: PlaceDetailView(place: place)) {
            ZStack(alignment: .topTrailing) {
                VStack {
                    ZStack {
                        AsyncImageView(imageUrl: place.images[0], width: 300, height: 200)
                        // Image("home-profile-bg")
                        //     .resizable()
                        //     .frame(width: 300, height: 200)

                        HStack {
                            VStack(alignment: .leading) {
                                Text(place.name)
                                    .font(themeManager.selectedTheme.boldBodyTextFont)
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(alignment: .bottomLeading)

                                ZStack {
                                    Text(place.type.formatTagName())
                                        .font(themeManager.selectedTheme.captionTextFont)
                                        .foregroundColor(themeManager.selectedTheme.bgTextColor)
                                }
                                .padding(.horizontal, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(themeManager.selectedTheme.accentColor)
                                )
                            }

                            Spacer()

                            Image(systemName: "star.fill")
                                .foregroundColor(themeManager.selectedTheme.accentColor)
                                .frame(width: 20, height: 20)
                            if let rating = place.rating {
                                Text("\(rating, specifier: "%.1f")")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    .foregroundColor(.white)
                            } else {
                                Text("N/A")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, 130)
                        .padding(.horizontal, 15)
                        .background(
                            Rectangle()
                                .fill(Color.black.opacity(0.7))
                                .frame(width: 300, height: 70)
                                .padding(.top, 130)
                        )
                    }
                    .frame(width: 300, height: 200)
                    .cornerRadius(10)
                }
                .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 10)

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
                    // Update immediately for better UX
                    isAdded = true
                    // Then verify with backend
                    checkPlaceStatus()
                },
                onRemovePlaceFromTrip: { place, trip in
                    // Check if the place is still in any trip after removal
                    checkPlaceStatus()
                }
            )
        }
        // Use onAppear instead of task to ensure it runs every time the view appears
        .onAppear {
            checkPlaceStatus()
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
                print("WideCard - Received placeAddedToTrip notification for place: \(place.id)")
                checkPlaceStatus()
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
                print("WideCard - Received placeRemovedFromTrip notification for place: \(place.id)")
                checkPlaceStatus()
            }
        }
    }
}
