import SwiftUI

struct SearchResultRow: View {
    let attraction: Attraction
    @StateObject var themeManager: ThemeManager = ThemeManager()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(attraction.name)
                        .font(themeManager.selectedTheme.boldBodyTextFont)
                        .foregroundColor(themeManager.selectedTheme.primaryColor)

                    Rating(rating: attraction.rating)

                    PriceAndTags(price: attraction.price, tags: attraction.tags)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
            }

            HStack {
                ForEach(attraction.images, id: \.self) { image in
                    AsyncImageView(imageUrl: image, width: 100, height: 75)
                }
            }


        }
    }
}
