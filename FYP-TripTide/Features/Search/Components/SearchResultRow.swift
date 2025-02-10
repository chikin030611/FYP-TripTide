import SwiftUI

struct SearchResultRow: View {
    let place: Place
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Image
            AsyncImageView(imageUrl: place.images[0], width: 90, height: 100)
                .frame(width: 90, height: 100)
            
            VStack(alignment: .leading, spacing: 2) {
                // Type
                ZStack {
                    Text(place.type.formatTagName())
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundColor(themeManager.selectedTheme.bgTextColor)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(themeManager.selectedTheme.accentColor)
                )

                // Name
                Text(place.name)
                    .font(themeManager.selectedTheme.boldBodyTextFont)
                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Rating
                Rating(rating: place.rating, ratingCount: place.ratingCount)
                
                // Tags
                TagGroup(tags: place.tags)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
