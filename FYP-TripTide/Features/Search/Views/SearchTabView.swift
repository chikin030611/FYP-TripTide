import SwiftUI


struct SearchTabView: View {
    @StateObject var themeManager = ThemeManager()
    @StateObject private var viewModel = SearchTabViewModel()
    @State private var searchText = ""
    @State private var isSearchActive = false
    @FocusState private var isFocused: Bool 
    @StateObject private var searchViewModel = SearchResultsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(themeManager.selectedTheme.secondaryColor)
                        
                        TextField("Search attractions...", text: $searchText)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled()
                            .focused($isFocused)
                            .onChange(of: searchText) { oldValue, newValue in
                                searchViewModel.filterAttractions(searchText: newValue)
                            }
                            .onChange(of: isFocused) { oldValue, newValue in
                                withAnimation(.spring(duration: 0.3)) {
                                    if newValue {
                                        isSearchActive = true
                                    }
                                }
                            }
                        
                        if !searchText.isEmpty {
                            Button {
                                withAnimation {
                                    searchText = ""
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding()
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(themeManager.selectedTheme.backgroundColor)
                    )

                    if isSearchActive {
                        Button {
                            withAnimation(.spring(duration: 0.3)) {
                                isFocused = false
                                isSearchActive = false
                                searchText = ""
                            }
                        } label: {
                            Text("Cancel")
                                .font(themeManager.selectedTheme.bodyTextFont)
                                .foregroundColor(themeManager.selectedTheme.secondaryColor)
                                .underline()
                        }
                        .padding(.horizontal, 4)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .padding(.horizontal)
                .animation(.spring(duration: 0.3), value: isFocused)
                .animation(.spring(duration: 0.3), value: searchText)

                ZStack {
                    if isSearchActive {
                        SearchResultsView(viewModel: searchViewModel)
                            .transition(.opacity)
                    } else {
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
                                                .foregroundColor(themeManager.selectedTheme.secondaryColor)
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
                        .transition(.opacity)
                    }
                }
                .animation(.spring(duration: 0.3), value: isSearchActive)
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
                        .foregroundColor(themeManager.selectedTheme.secondaryColor)
                        .underline()
                // }
            }
            
            CardGroup(cards: cards, style: .regular)
            
        }
    }
}
