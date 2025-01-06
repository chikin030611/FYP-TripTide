import SwiftUI

struct SearchResultRow: View {
    let attraction: Attraction
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Image
            AsyncImageView(imageUrl: attraction.images[0], width: 80, height: 80)
                .frame(width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 6) {
                // Name
                Text(attraction.name)
                    .font(themeManager.selectedTheme.boldBodyTextFont)
                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Rating
                Rating(rating: attraction.rating)
                
                // Tags
                TagGroup(tags: attraction.tags)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
