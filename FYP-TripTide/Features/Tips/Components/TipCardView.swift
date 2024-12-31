import SwiftUI


struct TipCardView: View {
    let tip: Tip
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImageView(imageUrl: tip.coverImage, height: 150)
            
            Text(tip.title)
                .font(themeManager.selectedTheme.titleFont)
                .foregroundStyle(themeManager.selectedTheme.primaryColor)
            
            HStack {

                ForEach(tip.author.split(separator: ","), id: \.self) { author in
                    HStack(spacing: 4) {
                        Text("By")
                            .font(themeManager.selectedTheme.captionTextFont)
                        Text(author)
                            .foregroundStyle(author == "TripTide" ? themeManager.selectedTheme.accentColor : .primary)
                    }
                }
                Spacer()
                Text(tip.publishDate.formatted(date: .abbreviated, time: .omitted))
            }
            .font(themeManager.selectedTheme.captionTextFont)
            .foregroundStyle(themeManager.selectedTheme.secondaryColor)
        }
    }
}