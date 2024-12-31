import SwiftUI

struct SearchHistoryRow: View {
    let attraction: Attraction
    @StateObject private var themeManager = ThemeManager()

    var body: some View {
        HStack {
            AsyncImageView(imageUrl: attraction.images[0], width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(attraction.name)
                    .font(themeManager.selectedTheme.boldBodyTextFont)
                    .foregroundColor(themeManager.selectedTheme.primaryColor)

                Rating(rating: attraction.rating)
                
                TagGroup(tags: attraction.tags)
            }
        }
    }
}