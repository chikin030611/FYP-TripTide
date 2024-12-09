import SwiftUI

struct TipsTabView: View {
    @StateObject private var viewModel = TipsTabViewModel()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
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

struct TipCardView: View {
    let tip: Tip
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: tip.coverImage)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
            } placeholder: {
                ProgressView()
            }
            .cornerRadius(10)
            
            Text(tip.title)
                .font(themeManager.selectedTheme.titleFont)
                .foregroundStyle(themeManager.selectedTheme.primaryColor)
            
            HStack {
                Text("By \(tip.author)")
                    .foregroundStyle(tip.author == "TripTide" ? themeManager.selectedTheme.accentColor : themeManager.selectedTheme.secondaryColor)
                Spacer()
                Text(tip.publishDate.formatted(date: .abbreviated, time: .omitted))
            }
            .font(themeManager.selectedTheme.captionTextFont)
            .foregroundStyle(themeManager.selectedTheme.secondaryColor)
        }
        .padding()
        // .background(themeManager.selectedTheme.backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
