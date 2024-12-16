import SwiftUI

struct PriceAndTags: View {
    let price: String
    let tags: [Tag]
    @StateObject var themeManager: ThemeManager = ThemeManager()

    var body: some View {
        HStack(spacing: 4) {
            Text(price)
                .font(themeManager.selectedTheme.captionTextFont)
                .foregroundColor(themeManager.selectedTheme.primaryColor)
                
            Text("•")
                .font(themeManager.selectedTheme.captionTextFont)
                .foregroundColor(themeManager.selectedTheme.primaryColor)

            TagGroup(tags: tags, themeManager: themeManager)
        }   
    }
}
