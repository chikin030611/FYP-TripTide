import SwiftUI

struct LargeCard: View {
    let place: Place
    @StateObject var themeManager = ThemeManager()

    init(place: Place) {
        self.place = place
    }

    var body: some View {
        NavigationLink(destination: PlaceDetailView(place: place)) {
            VStack(alignment: .leading, spacing: 4) {
                AsyncImageView(imageUrl: place.images[0], width: 220, height: 180)

                Text(place.name)
                    .font(themeManager.selectedTheme.boldBodyTextFont)
                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Rating(rating: place.rating)

                TagGroup(tags: place.tags)
            }
            .frame(width: 220, alignment: .leading)
        }
    }
}
