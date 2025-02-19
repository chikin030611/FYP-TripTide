import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var highlyRatedCards: [Card] = []
}