import SwiftUI

struct TipDetailView: View {
    @StateObject private var viewModel: TipDetailViewModel
    @StateObject private var themeManager = ThemeManager()
    
    init(tip: Tip) {
        _viewModel = StateObject(wrappedValue: TipDetailViewModel(tip: tip))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.tip.title)
                        .font(themeManager.selectedTheme.largeTitleFont)
                        .foregroundStyle(themeManager.selectedTheme.primaryColor)
                    
                    HStack {
                        HStack(spacing: 4) {
                            Text("By")
                                .font(themeManager.selectedTheme.captionTextFont)
                            Text(viewModel.tip.author)
                                .foregroundStyle(viewModel.tip.author == "TripTide" ? themeManager.selectedTheme.accentColor : .primary)
                        }
                        .font(themeManager.selectedTheme.captionTextFont)
                        Spacer()
                        Text(viewModel.tip.publishDate.formatted(date: .abbreviated, time: .omitted))
                            .font(themeManager.selectedTheme.captionTextFont)
                    }
                    .foregroundStyle(themeManager.selectedTheme.secondaryColor)
                }

                // Cover Image
                AsyncImageView(imageUrl: viewModel.tip.coverImage, height: 200)
                
                // Content
                ForEach(Array(viewModel.tip.content.enumerated()), id: \.offset) { _, content in
                    TipContentView(content: content)
                }
                
                // Reference
                VStack(alignment: .leading) {
                    Text("Reference: \n\(viewModel.tip.reference)")
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundStyle(themeManager.selectedTheme.secondaryColor)
                    Link(destination: URL(string: viewModel.tip.referenceLink)!) {
                        Text(viewModel.tip.referenceLink)
                            .font(themeManager.selectedTheme.captionTextFont)
                            .underline()
                            .foregroundStyle(themeManager.selectedTheme.secondaryColor)
                    }
                }
                .padding(.vertical, 15)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

