import SwiftUI

struct Rating: View {
    let rating: Float?
    let ratingCount: Int
    @StateObject var themeManager: ThemeManager = ThemeManager()
    
    var body: some View {
        if let ratingValue = rating {
            HStack(spacing: 3) {
                Text(String(format: "%.1f", ratingValue))
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)

                ForEach(0..<5) { index in
                    starImage(for: Float(index), rating: ratingValue)
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundStyle(themeManager.selectedTheme.accentColor)
                }

                Text("(\(ratingCount))")
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
            }
        } else {
            HStack(spacing: 3) {
                Text("No Rating")
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundStyle(themeManager.selectedTheme.secondaryColor)
                
                Text("(\(ratingCount))")
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundStyle(themeManager.selectedTheme.secondaryColor)
            }
        }
    }
    
    @ViewBuilder
    private func starImage(for index: Float, rating: Float) -> some View {
        if rating >= index + 1 {
            Image(systemName: "star.fill")
        } else if rating > index {
            Image(systemName: "star.leadinghalf.filled")
        } else {
            Image(systemName: "star")
        }
    }
}

