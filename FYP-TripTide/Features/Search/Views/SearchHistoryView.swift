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

// Helper view for flowing layout of keyword tags
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for index in subviews.indices {
            let point = result.points[index]
            subviews[index].place(at: CGPoint(x: point.x + bounds.minX, y: point.y + bounds.minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var points: [CGPoint] = []
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var maxHeight: CGFloat = 0
            var rowMaxY: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > width, x > 0 {
                    x = 0
                    y = rowMaxY + spacing
                }
                
                points.append(CGPoint(x: x, y: y))
                x += size.width + spacing
                maxHeight = max(maxHeight, size.height)
                rowMaxY = y + maxHeight
            }
            
            size = CGSize(width: width, height: rowMaxY)
        }
    }
} 