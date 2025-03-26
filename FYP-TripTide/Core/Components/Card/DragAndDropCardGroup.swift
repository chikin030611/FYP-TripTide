import SwiftUI
import UniformTypeIdentifiers  // Add this import for UTType

struct DragAndDropCardGroup: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var cards: [Place]
    @State private var draggedItem: Place?
    
    init(places: [Place]) {
        _cards = State(initialValue: places)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.flexible())], spacing: 16) {
                ForEach(cards) { place in
                    DragAndDropCard(place: place)
                        .onDrag {
                            // Set the currently dragged item
                            self.draggedItem = place
                            
                            // Return an NSItemProvider that contains the ID of the card
                            return NSItemProvider(object: place.id as NSString)
                        }
                        .onDrop(of: [UTType.text.identifier], delegate: CardDropDelegate(
                            item: place,
                            items: $cards,
                            draggedItem: $draggedItem)
                        )
                        .animation(.default, value: cards)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct DragAndDropCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let place: Place

    var body: some View {
        ZStack {
            AsyncImageView(imageUrl: place.images[0], width: 150, height: 130)

            // Gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.01), Color.black.opacity(0.5)]),
                startPoint: .center,
                endPoint: .bottom
            )

            Text(place.name)
                .font(themeManager.selectedTheme.boldBodyTextFont)
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 130, height: 110, alignment: .bottomLeading)
        }
        .frame(width: 150, height: 130)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// Custom drop delegate to handle the drop operation
struct CardDropDelegate: DropDelegate {
    let item: Place
    @Binding var items: [Place]
    @Binding var draggedItem: Place?
    
    // Called when a drag operation enters this view
    func dropEntered(info: DropInfo) {
        // Only react if we have a valid dragged item
        guard let draggedItem = self.draggedItem else { return }
        guard let fromIndex = items.firstIndex(where: { $0.id == draggedItem.id }) else { return }
        guard let toIndex = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        // Don't do anything if the indices are the same
        if fromIndex == toIndex {
            return
        }
        
        // Reorder the items
        withAnimation {
            let movedItem = items.remove(at: fromIndex)
            items.insert(movedItem, at: toIndex)
        }
    }
    
    // Required implementation: checks if the drop should be processed
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    // Called when the drop operation completes
    func performDrop(info: DropInfo) -> Bool {
        // Reset the dragged item
        self.draggedItem = nil
        return true
    }
}
