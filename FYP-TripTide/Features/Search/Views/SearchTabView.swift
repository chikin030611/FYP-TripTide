import SwiftUI


struct SearchTabView: View {
    @StateObject var themeManager = ThemeManager()
    @StateObject private var viewModel = SearchTabViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
                
                TextField("Search attractions...", text: $searchText)
                    .textFieldStyle(.plain)
                
            }
            .padding()
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(themeManager.selectedTheme.backgroundColor)
            )
            .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading) {
                    // Highly Rated
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: viewModel.highlyRatedSection.icon)
                                .foregroundColor(themeManager.selectedTheme.accentColor)
                            Text(viewModel.highlyRatedSection.title)
                                .font(themeManager.selectedTheme.boldTitleFont)
                                .foregroundStyle(themeManager.selectedTheme.primaryColor)

                            Spacer()

                            // NavigationLink(destination: AttractionDetailView(attraction: attraction)) {
                                Text("View All")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                                    .underline()
                            // }
                        }
                        
                        CardGroup(cards: viewModel.highlyRatedCards, style: .large)
            
                    }
                    
                    // Restaurant
                    RegularBodySection(icon: viewModel.restaurantSection.icon,
                                title: viewModel.restaurantSection.title,
                                cards: viewModel.restaurantCards)
                        .padding(.vertical, 5)
                    
                    // Accommodation
                    RegularBodySection(icon: viewModel.accommodationSection.icon,
                                title: viewModel.accommodationSection.title,
                                cards: viewModel.accommodationCards)
                        .padding(.vertical, 5)
                }
                .padding()
            }
        }
    }
}

// MARK: - Body Section
private struct RegularBodySection: View {
    @StateObject var themeManager = ThemeManager()
    
    let icon: String
    var title: String
    var cards: [Card]
    // var attraction: Attraction

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(themeManager.selectedTheme.accentColor)
                Text(title)
                    .font(themeManager.selectedTheme.boldTitleFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)

                Spacer()

                // NavigationLink(destination: AttractionDetailView(attraction: attraction)) {
                    Text("View All")
                        .font(themeManager.selectedTheme.bodyTextFont)
                        .foregroundColor(themeManager.selectedTheme.primaryColor)
                        .underline()
                // }
            }
            
            CardGroup(cards: cards, style: .regular)
            
        }
    }
}
