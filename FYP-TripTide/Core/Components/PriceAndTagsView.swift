import SwiftUI

struct PriceAndTagsView: View {
    let price: String
    let tags: [Tag]
    @StateObject var themeManager: ThemeManager = ThemeManager()

    var body: some View {
        HStack {
            Text(price)
                .font(themeManager.selectedTheme.captionTextFont)
                
            Text("•")
                .font(themeManager.selectedTheme.captionTextFont)

            ForEach(tags, id: \.name) { tag in
                Text(tag.name)
                    .font(themeManager.selectedTheme.captionTextFont)
                if tag != tags.last {
                    Text("•")
                        .font(themeManager.selectedTheme.captionTextFont)
                }
            }
        }   
    }
}
