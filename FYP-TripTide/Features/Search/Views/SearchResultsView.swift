import SwiftUI

// TODO: Add filter


struct SearchResultsView: View {
    @StateObject var themeManager = ThemeManager()
    @ObservedObject var viewModel: SearchResultsViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ScrollView {
            if viewModel.searchResults.isEmpty && viewModel.currentSearchText.isEmpty {
                SearchHistoryView(viewModel: viewModel.searchHistoryViewModel)
                    .transition(.opacity)
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.searchResults) { attraction in
                        NavigationLink {
                            AttractionDetailView(attraction: attraction)
                                .onAppear {
                                    viewModel.addRecentlyViewed(attraction)
                                }
                        } label: {
                            SearchResultRow(attraction: attraction)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 5)
                    }
                    
                    if viewModel.searchResults.isEmpty {
                        Text("No results found")
                            .foregroundColor(themeManager.selectedTheme.secondaryColor)
                            .padding(.top, 32)
                    }
                    
                    Divider()
                }
                .padding(.vertical)
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
}
