import SwiftUI

struct SearchResultRow: View {
    let place: Place
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Image
            AsyncImageView(imageUrl: place.images[0], width: 80, height: 80)
                .frame(width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 6) {
                // Name
                Text(place.name)
                    .font(themeManager.selectedTheme.boldBodyTextFont)
                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Rating
                Rating(rating: place.rating)
                
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
