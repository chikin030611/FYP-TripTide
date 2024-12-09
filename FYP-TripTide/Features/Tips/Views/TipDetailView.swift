import SwiftUI

struct TipDetailView: View {
    
    let tip: Tip
    @StateObject var themeManager = ThemeManager()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(tip.title)
                        .font(themeManager.selectedTheme.largeTitleFont)
                        .foregroundStyle(themeManager.selectedTheme.primaryColor)
                    
                    HStack {
                        Text("By \(tip.author)")
                            .font(themeManager.selectedTheme.captionTextFont)
                        Spacer()
                        Text(tip.publishDate.formatted(date: .abbreviated, time: .omitted))
                            .font(themeManager.selectedTheme.captionTextFont)
                    }
                    .foregroundStyle(themeManager.selectedTheme.secondaryColor)
                }
                .padding(.horizontal)
                
                // Content
                ForEach(Array(tip.content.enumerated()), id: \.offset) { _, content in
                    BlogContentView(content: content)
                }
                
                // Reference
                VStack(alignment: .leading) {
                    Text("Reference: \n\(tip.reference)")
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundStyle(themeManager.selectedTheme.secondaryColor)
                        .padding(.horizontal)
                    Link(destination: URL(string: tip.referenceLink)!) {
                        Text(tip.referenceLink)
                            .font(themeManager.selectedTheme.captionTextFont)
                            .underline()
                            .foregroundStyle(themeManager.selectedTheme.secondaryColor)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

