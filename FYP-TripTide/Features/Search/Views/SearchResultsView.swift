import SwiftUI

// TODO: Add filter


struct SearchResultsView: View {
    @StateObject private var themeManager: ThemeManager = ThemeManager()
    @ObservedObject var viewModel: SearchResultsViewModel
    
    var body: some View {
        ScrollView {
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
}
