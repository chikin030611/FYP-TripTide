import SwiftUI

struct CardGroup: View {
    @State var cards: [Card]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(cards, id: \.placeId) { card in
                    card
                }
            }
        }
    }
}