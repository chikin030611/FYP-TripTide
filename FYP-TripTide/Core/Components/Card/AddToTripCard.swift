import SwiftUI

struct AddToTripCard: View {
    @StateObject private var themeManager = ThemeManager()

    @Environment(\.screenSize) private var screenSize  // We'll need to create this environment key

    // Add onSelect callback
    var onSelect: (Trip) -> Void

    // Calculate relative dimensions based on screen width
    private var cardWidth: CGFloat {
        screenSize.width * 0.7  // Takes up 85% of screen width
    }

    private var cardHeight: CGFloat {
        cardWidth * 0.7  // Maintains roughly the same aspect ratio as original (350/325)
    }

    private var overlayHeight: CGFloat {
        cardHeight * 0.4  // About 50/350 of card height
    }

    private var titlePadding: CGFloat {
        cardHeight * 0.6  // About 150/350 of card height
    }

    @State private var isAdded = false
    @State private var trip: Trip

    init(trip: Trip, onSelect: @escaping (Trip) -> Void) {
        self.trip = trip
        self.onSelect = onSelect
    }

    var body: some View {
        VStack {
            ZStack {
                // AsyncImageView(imageUrl: trip.image, width: cardWidth, height: cardHeight)
                Image(trip.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth, height: cardHeight)
                    .cornerRadius(10)

                HStack {
                    VStack(alignment: .leading) {
                        Text(trip.name)
                            .font(themeManager.selectedTheme.boldBodyTextFont)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(alignment: .bottomLeading)

                        HStack(alignment: .top) {
                            Image(systemName: "calendar")
                                .frame(width: 20, height: 20)
                            Text("\(trip.numOfDays) days")
                                .font(themeManager.selectedTheme.bodyTextFont)
                        }
                        .padding(.horizontal, 8)
                        .background(
                            Rectangle()
                                .cornerRadius(10)
                                .foregroundColor(themeManager.selectedTheme.backgroundColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 25)
                        )
                        .foregroundColor(themeManager.selectedTheme.primaryColor)
                        .frame(alignment: .topLeading)

                    }

                    Spacer()

                    HStack(alignment: .top) {
                        Image(systemName: "heart.fill")
                            .frame(width: 20, height: 20)
                            .foregroundColor(themeManager.selectedTheme.bgTextColor)
                        Text("\(trip.savedCount) Saves")
                            .font(themeManager.selectedTheme.bodyTextFont)
                            .foregroundColor(themeManager.selectedTheme.bgTextColor)
                    }
                    .padding(.horizontal, 8)
                    .background(
                        Rectangle()
                            .cornerRadius(10)
                            .foregroundColor(themeManager.selectedTheme.accentColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 25)
                    )
                    .frame(alignment: .topLeading)

                }
                .padding(.top, titlePadding)
                .padding(.horizontal, cardWidth * 0.046)  // About 15/325 of card width
                .background(
                    Rectangle()
                        .fill(Color.black.opacity(0.7))
                        .frame(width: cardWidth, height: overlayHeight)
                        .padding(.top, titlePadding)
                )
            }
            .frame(width: cardWidth, height: cardHeight)
            .cornerRadius(10)
        }
        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 10)
        .onTapGesture {
            onSelect(trip)
        }
    }
}
