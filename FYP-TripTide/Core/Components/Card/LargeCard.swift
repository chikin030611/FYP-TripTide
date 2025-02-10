import SwiftUI

struct LargeCard: View {
    let place: Place
    @StateObject var themeManager = ThemeManager()

    init(place: Place) {
        self.place = place
    }

    var body: some View {
        NavigationLink(destination: PlaceDetailView(place: place)) {
            VStack(alignment: .leading, spacing: 2) {
                AsyncImageView(imageUrl: place.images[0], width: 220, height: 180)
                    .padding(.bottom, 4)
                
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
        }
    }
}
