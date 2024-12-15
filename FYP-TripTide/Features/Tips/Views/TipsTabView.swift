import SwiftUI

struct TipsTabView: View {
    @StateObject private var viewModel = TipsTabViewModel()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.tips) { tip in
                        NavigationLink(destination: TipDetailView(tip: tip)) {
                            TipCardView(tip: tip)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Travel Tips")
        }
        .onAppear {
            viewModel.fetchTips()
        }
    }
}

