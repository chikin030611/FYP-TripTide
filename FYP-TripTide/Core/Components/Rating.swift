import SwiftUI

struct Rating: View {
    let rating: Float
    @StateObject var themeManager: ThemeManager = ThemeManager()
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5) { index in
                starImage(for: Float(index))
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundStyle(themeManager.selectedTheme.accentColor)
            }

            Text(String(format: "(%.1f)", rating))
                .font(themeManager.selectedTheme.captionTextFont)
                .foregroundStyle(themeManager.selectedTheme.primaryColor)
        }
    }
    
    @ViewBuilder
    private func starImage(for index: Float) -> some View {
        if rating >= index + 1 {
            Image(systemName: "star.fill")
        } else if rating > index {
            Image(systemName: "star.leadinghalf.filled")
        } else {
            Image(systemName: "star")
        }
    }
}

