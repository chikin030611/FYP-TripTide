import SwiftUI

enum CardStyle {
    case regular
    case large
}

struct CardGroup: View {
    let cards: [Card]
    let style: CardStyle
    
    init(cards: [Card], style: CardStyle = .regular) {
        self.cards = cards
        self.style = style
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top) {
                ForEach(cards, id: \.attraction.id) { card in
                    switch style {
                    case .regular:
                        Card(attraction: card.attraction)
                    case .large:
                        LargeCard(attraction: card.attraction)
                    }
                }
            }
        }
    }
}