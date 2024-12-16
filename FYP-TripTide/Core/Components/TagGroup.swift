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
            Text(name)
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