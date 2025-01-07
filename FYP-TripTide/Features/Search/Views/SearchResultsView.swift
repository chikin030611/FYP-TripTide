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
                LazyVStack(spacing: 16) {
                    if viewModel.isLoading && viewModel.currentPage == 0 {
                        ProgressView()
                            .padding(.top, 32)
                    } else if let error = viewModel.error {
                        Text("Error: \(error.localizedDescription)")
                            .foregroundColor(.red)
                            .padding(.top, 32)
                    } else {
                        ForEach(viewModel.searchResults) { place in
                            NavigationLink {
                                PlaceDetailView(place: place)
                                    .onAppear {
                                        viewModel.addRecentlyViewed(place)
                                    }
                            } label: {
                                SearchResultRow(place: place)
                                    .padding(.horizontal)
                            }
                            .padding(.vertical, 5)
                        }
                        
                        if viewModel.searchResults.isEmpty {
                            Text("No results found")
                                .foregroundColor(themeManager.selectedTheme.secondaryColor)
                                .padding(.top, 32)
                        }
                        
                        if viewModel.isLoading && !viewModel.searchResults.isEmpty {
                            ProgressView()
                                .padding()
                        }
                        
                        if !viewModel.searchResults.isEmpty && !viewModel.isLoading {
                            GeometryReader { geometry in
                                Color.clear.preference(key: ScrollViewPositionKey.self,
                                    value: geometry.frame(in: .global).maxY)
                            }
                            .frame(height: 20)
                        }
                        
                        Divider()
                    }
                }
                .padding(.vertical)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .onPreferenceChange(ScrollViewPositionKey.self) { maxY in
            let screenHeight = UIScreen.main.bounds.height
            
            if maxY < screenHeight + 200 
                && viewModel.hasMoreResults 
                && !viewModel.isLoading 
                && !viewModel.currentSearchText.isEmpty {
                Task {
                    await viewModel.loadNextPage()
                }
            }
        }
    }
}

struct ScrollViewPositionKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
