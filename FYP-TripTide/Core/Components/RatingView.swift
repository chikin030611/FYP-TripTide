import SwiftUI

struct RatingView: View {
    let rating: Int
    @StateObject var themeManager: ThemeManager = ThemeManager()
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<rating, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundStyle(themeManager.selectedTheme.accentColor)
            }
            
            ForEach(0..<5-rating, id: \.self) { _ in
                Image(systemName: "star")
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundStyle(themeManager.selectedTheme.accentColor)
            }

            Text("(\(rating))")
                .font(themeManager.selectedTheme.captionTextFont)
                .foregroundStyle(themeManager.selectedTheme.primaryColor)
        }
    }
}
