import SwiftUI

enum TagButtonVariant {
    case addTag
    case removeTag
}

struct TagLayout: View {
    @StateObject var themeManager: ThemeManager = ThemeManager()
    
    let tags: [Tag]
    let onTagSelected: (Tag) -> Void
    let variant: TagButtonVariant
    
    var body: some View {
        switch variant {
        case .addTag:
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.name) { tag in
                    Button(tag.name) {
                        onTagSelected(tag)
                    }
                    .buttonStyle(TagButtonStyle())
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
