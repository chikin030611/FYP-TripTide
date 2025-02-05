import SwiftUI


struct SearchTabView: View {
    @StateObject var themeManager = ThemeManager()
    @StateObject private var viewModel = SearchTabViewModel()
    @StateObject private var searchViewModel: SearchResultsViewModel
    @State private var searchText = ""
    @State private var isSearchActive = false
    @State private var isFilterSheetPresented = false
    @FocusState private var isFocused: Bool 
    @StateObject private var filterViewModel = FilterViewModel()
    @State private var showingFilterSheet = false
    
    init() {
        // Initialize searchViewModel with shared searchHistoryViewModel
        let searchHistoryVM = SearchHistoryViewModel()
        _searchViewModel = StateObject(wrappedValue: SearchResultsViewModel(searchHistoryViewModel: searchHistoryVM))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(themeManager.selectedTheme.secondaryColor)
                        
                        TextField("Search places...", text: $searchText)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled()
                            .focused($isFocused)
                            .onSubmit {
                                if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                                    Task {
                                        await searchViewModel.filterPlaces(searchText: searchText, tags: Array(filterViewModel.selectedTags).map { $0.name })
                                        searchViewModel.searchHistoryViewModel.addRecentSearch(searchText)
                                    }
                                } else {
                                    Task {
                                        await searchViewModel.filterPlaces(searchText: "")
                                    }
                                }
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
                                    // Clear search results when text is cleared
                                    Task {
                                        await searchViewModel.filterPlaces(searchText: "")
                                    }
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
                                // Clear search results to show history view
                                Task {
                                    await searchViewModel.filterPlaces(searchText: "")
                                    filterViewModel.selectedTags = []
                                }
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

                if isSearchActive {
                    HStack {
                        Button {
                            showingFilterSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                Text("Filter")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                            }
                        }
                        .buttonStyle(RectangularButtonStyle())

                        if filterViewModel.selectedTags.count > 0 {
                            Button {
                                showingFilterSheet = true
                            } label: {
                                Text("\(filterViewModel.selectedTags.count) filters is selected")
                            }
                            .buttonStyle(SecondaryTagButtonStyle())

                            Spacer()

                            Button {
                                filterViewModel.selectedTags = []
                                searchText = ""  // Clear search text
                                Task {
                                    await searchViewModel.filterPlaces(searchText: "")  // This will show history view
                                }
                            } label: {
                                Text("Clear")
                            }
                            .buttonStyle(SecondaryTagButtonStyle())
                        } else {
                            Spacer()
                        }
                    }
                    .sheet(isPresented: $showingFilterSheet) {
                        FilterSheet(viewModel: filterViewModel)
                    }
                    .padding(.horizontal)
                }

                ZStack {
                    if isSearchActive {
                        SearchResultsView(viewModel: searchViewModel)
                            .environment(\.onSearch) { searchText in
                                self.searchText = searchText
                                filterViewModel.selectedTags = []  // Clear filters when history search is clicked
                                Task {
                                    await searchViewModel.filterPlaces(searchText: searchText, tags: [])
                                    searchViewModel.searchHistoryViewModel.addRecentSearch(searchText)
                                }
                            }
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

                                        // NavigationLink(destination: PlaceDetailView(place: place)) {
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
                                
                                // Lodging
                                RegularBodySection(icon: viewModel.lodgingSection.icon,
                                            title: viewModel.lodgingSection.title,
                                            cards: viewModel.lodgingCards)
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
        .task {
            await viewModel.loadData()
            await filterViewModel.loadTags()
            
            // Set up filter handling
            filterViewModel.onApplyAndSearchFilter = { tags in
                Task {
                    if searchText.isEmpty {
                        // Search with only tags
                        await searchViewModel.filterPlaces(searchText: "", tags: tags)
                    } else {
                        // Search with both text and tags
                        await searchViewModel.filterPlaces(searchText: searchText, tags: tags)
                    }
                }
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
    // var place: Place

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(themeManager.selectedTheme.accentColor)
                Text(title)
                    .font(themeManager.selectedTheme.boldTitleFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)

                Spacer()

                // NavigationLink(destination: PlaceDetailView(place: place)) {
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
