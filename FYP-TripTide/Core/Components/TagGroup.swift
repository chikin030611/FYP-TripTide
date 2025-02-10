import SwiftUI

struct TagGroup: View {
    let tags: [Tag]
    @StateObject var themeManager: ThemeManager = ThemeManager()

    var body: some View {
        FlowLayout(spacing: 2) {
            ForEach(tags, id: \.name) { tag in
                TagView(name: tag.name)
            }
        }
    }
}

struct TagView: View {
    let name: String
    @StateObject var themeManager: ThemeManager = ThemeManager()

    var body: some View {
        ZStack {
            Text(name.formatTagName())
                .font(themeManager.selectedTheme.captionTextFont)
                .foregroundColor(themeManager.selectedTheme.primaryColor)
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(themeManager.selectedTheme.backgroundColor)
        )
    }
}
