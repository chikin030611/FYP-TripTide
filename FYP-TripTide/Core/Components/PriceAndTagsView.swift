import SwiftUI

struct PriceAndTagsView: View {
    let price: String
    let tags: [Tag]
    @StateObject var themeManager: ThemeManager = ThemeManager()

    var body: some View {
        HStack {
            Text(price)
                .font(themeManager.selectedTheme.captionTextFont)
                .foregroundColor(themeManager.selectedTheme.primaryColor)
                
            Text("•")
                .font(themeManager.selectedTheme.captionTextFont)
                .foregroundColor(themeManager.selectedTheme.primaryColor)
            ForEach(tags, id: \.name) { tag in
                Text(tag.name)
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                if tag != tags.last {
                    Text("•")
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundColor(themeManager.selectedTheme.primaryColor)
                }
            }
        }   
    }
}
