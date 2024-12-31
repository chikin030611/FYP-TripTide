import SwiftUI

struct SearchResultRow: View {
    let attraction: Attraction
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        HStack(spacing: 12) {
            // Image
            AsyncImageView(imageUrl: attraction.images[0], width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 6) {
                // Name
                Text(attraction.name)
                    .font(themeManager.selectedTheme.boldBodyTextFont)
                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                
                // Rating
                Rating(rating: attraction.rating)
                
                // Tags
                TagGroup(tags: attraction.tags)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
    }
}
