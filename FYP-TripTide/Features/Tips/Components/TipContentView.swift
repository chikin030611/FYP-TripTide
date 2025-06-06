import SwiftUI


struct TipContentView: View {
    let content: TipContent
    @StateObject var themeManager = ThemeManager()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch content {
            case .text(let text):
                Text(text)
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
                
            case .image(let url):
                AsyncImageView(imageUrl: url)
                
            case .header(let text):
                Text(text)
                    .font(themeManager.selectedTheme.titleFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
                
            case .quote(let text):
                Text(text)
                    .font(themeManager.selectedTheme.bodyTextFont.italic())
                    .foregroundStyle(themeManager.selectedTheme.secondaryColor)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(themeManager.selectedTheme.secondaryColor.opacity(0.1))
                    .overlay(
                        Rectangle()
                            .fill(themeManager.selectedTheme.primaryColor)
                            .frame(width: 4)
                            .padding(.vertical, 4),
                        alignment: .leading
                    )
                
            case .bulletPoints(let points):
                ForEach(points, id: \.self) { point in
                    HStack(alignment: .top) {
                        Text("•")
                        Text(point)
                    }
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
                }

            case .link(let url, let text):
                Link(destination: URL(string: url)!) {
                    Text(text)
                        .font(themeManager.selectedTheme.bodyTextFont)
                        .foregroundStyle(themeManager.selectedTheme.accentColor)
                        .underline()
                }
            }
        }
    }
}