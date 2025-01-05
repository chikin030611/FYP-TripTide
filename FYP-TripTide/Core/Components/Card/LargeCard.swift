import SwiftUI

struct LargeCard: View {
    let attraction: Attraction
    @StateObject var themeManager = ThemeManager()

    init(attraction: Attraction) {
        self.attraction = attraction
    }

    var body: some View {
        NavigationLink(destination: AttractionDetailView(attraction: attraction)) {
            VStack(alignment: .leading, spacing: 4) {
                AsyncImageView(imageUrl: attraction.images[0], width: 220, height: 180)

                Text(attraction.name)
                    .font(themeManager.selectedTheme.boldBodyTextFont)
                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Rating(rating: attraction.rating)

                TagGroup(tags: attraction.tags)
            }
            .frame(width: 220, alignment: .leading)
        }
    }
}
