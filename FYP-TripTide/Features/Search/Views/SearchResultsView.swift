import SwiftUI

// TODO: Add filter


struct SearchResultsView: View {
    @StateObject private var themeManager: ThemeManager = ThemeManager()
    @ObservedObject var viewModel: SearchResultsViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ScrollView {
            if viewModel.searchResults.isEmpty && viewModel.currentSearchText.isEmpty {
                SearchHistoryView()
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.searchResults) { attraction in
                        NavigationLink {
                            AttractionDetailView(attraction: attraction)
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
