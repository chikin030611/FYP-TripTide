import SwiftUI

class TipDetailViewModel: ObservableObject {
    @Published var tip: Tip
    
    init(tip: Tip) {
        self.tip = tip
    }
}
