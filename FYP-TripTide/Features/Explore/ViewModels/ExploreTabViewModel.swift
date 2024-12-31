import SwiftUI

class ExploreTabViewModel: ObservableObject {
    @Published var highlyRatedCards: [Card] = []
}