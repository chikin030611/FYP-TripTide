import SwiftUI

enum TagButtonVariant {
    case addTag
    case removeTag
}

struct TagLayout: View {
    @StateObject var themeManager: ThemeManager = ThemeManager()
    
    let tags: [Tag]
    let variant: TagButtonVariant
    let onTagSelected: (Tag) -> Void
    
    var body: some View {
        switch variant {
        case .addTag:
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.name) { tag in
                    Button(tag.name) {
                        onTagSelected(tag)
                    }
                    .buttonStyle(RectangularButtonStyle())
                }
            }
        case .removeTag:
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.name) { tag in
                    Button(tag.name) {
                        onTagSelected(tag)
                    }
                    .buttonStyle(RemoveTagButtonStyle())
                }
            }
        }
    }
}
