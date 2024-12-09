import SwiftUI

class TipsTabViewModel: ObservableObject {
    @Published var tips: [Tip] = []
    
    func fetchTips() {
        // Temporarily using mock data until database is set up
        tips = sampleTips
    }
}

