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

struct TipCardView: View {
    let tip: Tip
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        VStack(alignment: .leading) {
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

                ForEach(tip.author.split(separator: ","), id: \.self) { author in
                    HStack(spacing: 4) {
                        Text("By")
                            .font(themeManager.selectedTheme.captionTextFont)
                        Text(author)
                            .foregroundStyle(author == "TripTide" ? themeManager.selectedTheme.accentColor : .primary)
                    }
                }
                Spacer()
                Text(tip.publishDate.formatted(date: .abbreviated, time: .omitted))
            }
            .font(themeManager.selectedTheme.captionTextFont)
            .foregroundStyle(themeManager.selectedTheme.secondaryColor)
        }
    }
}
