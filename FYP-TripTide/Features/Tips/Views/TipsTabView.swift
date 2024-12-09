import SwiftUI

struct TipsTabView: View {
    var body: some View {
        TipDetailView(tip: getTip(by: UUID()) ?? transportTip)
    }
}
