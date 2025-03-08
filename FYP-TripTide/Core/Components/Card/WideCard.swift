import SwiftUI

struct WideCard: View {

    @StateObject var themeManager = ThemeManager()
    @State private var isAdded: Bool = false
    @State private var isAnimating: Bool = false
    @State private var showAddToTripSheet = false

    let place: Place

    init(place: Place) {
        self.place = place
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
                            Text("\(place.rating, specifier: "%.1f")")
                                .font(themeManager.selectedTheme.bodyTextFont)
                                .foregroundColor(.white)
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
            }
        }
        .sheet(isPresented: $showAddToTripSheet) {
            AddToTripSheet(
                place: place,
                onAddPlaceToTrip: { place, trip in
                    isAdded = true  // Update the button state when a place is added
                }
            )
        }
    }
}
