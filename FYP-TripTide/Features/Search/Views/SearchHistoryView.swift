import SwiftUI

struct SearchHistoryView: View {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var viewModel = SearchHistoryViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Recent Tags
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Tags")
                    .font(themeManager.selectedTheme.boldTitleFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
                    
                
                FlowLayout(spacing: 8) {
                    if !viewModel.recentTags.isEmpty {
                        ForEach(viewModel.recentTags, id: \.self) { keyword in
                            Text(keyword)
                                .font(themeManager.selectedTheme.bodyTextFont)
                                .foregroundColor(themeManager.selectedTheme.primaryColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(themeManager.selectedTheme.backgroundColor)
                            )
                        }
                    } else {
                        Text("No recent tags")
                            .font(themeManager.selectedTheme.bodyTextFont)
                            .foregroundColor(themeManager.selectedTheme.secondaryColor)
                    }
                }
            }

            // Recently Viewed
            VStack(alignment: .leading, spacing: 16) {
                Text("Recently Viewed")
                    .font(themeManager.selectedTheme.boldTitleFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
                
                if !viewModel.recentlyViewedAttractions.isEmpty {
                    ForEach(viewModel.recentlyViewedAttractions) { attraction in
                        NavigationLink {
                            AttractionDetailView(attraction: attraction)
                        } label: {
                            SearchHistoryRow(attraction: attraction)
                        }
                    }
                } else {
                    Text("No recently viewed attractions")
                        .font(themeManager.selectedTheme.bodyTextFont)
                        .foregroundColor(themeManager.selectedTheme.secondaryColor)
                }
            }
        }
        .padding()
    }
}
