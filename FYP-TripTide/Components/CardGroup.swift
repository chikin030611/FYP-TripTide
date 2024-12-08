import SwiftUI

struct CardGroup: View {
    @State var cards: [Card]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(cards, id: \.attractionId) { card in
                    card
                }
            }
        }
    }
}