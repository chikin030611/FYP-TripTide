import SwiftUI

struct SearchHistoryRow: View {
    let place: Place
    @StateObject private var themeManager = ThemeManager()

    var body: some View {
        HStack {
            AsyncImageView(imageUrl: place.images[0], width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(place.name)
                    .font(themeManager.selectedTheme.boldBodyTextFont)
                    .foregroundColor(themeManager.selectedTheme.primaryColor)

                Rating(rating: place.rating)
                
                TagGroup(tags: place.tags)
            }
        }
    }
}