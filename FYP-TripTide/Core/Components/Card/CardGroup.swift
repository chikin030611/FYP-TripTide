import SwiftUI

enum CardStyle {
    case regular
    case large
    case wide
}

struct CardGroup: View {
    let cards: [Card]
    let style: CardStyle
    let spacing: CGFloat
    let bottomPadding: CGFloat

    init(cards: [Card], style: CardStyle = .regular) {
        self.cards = cards
        self.style = style
        self.spacing = {
            switch style {
                case .regular: return 10
                case .large: return 20
                case .wide: return 30
            }
        }()
        self.bottomPadding = {
            switch style {
                case .wide: return 30
                default: return 0
            }
        }()
    }
    
    var body: some View {

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: self.spacing) {
                ForEach(cards, id: \.place.id) { card in
                    switch style {
                    case .regular:
                        Card(place: card.place)
                    case .large:
                        LargeCard(place: card.place)
                    case .wide:
                        WideCard(place: card.place)
                    }
                }
            }
            .padding(.bottom, bottomPadding)
            .padding(.horizontal, 10)
        }
    }
}