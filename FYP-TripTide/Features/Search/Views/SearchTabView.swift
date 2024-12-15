import SwiftUI

// TODO: Add filter
// TODO: Add background color in themeManager


struct SearchTabView: View {
    @StateObject private var viewModel = SearchTabViewModel()
    @StateObject private var themeManager: ThemeManager = ThemeManager()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(themeManager.selectedTheme.secondaryColor)
                    
                    TextField("Search attractions...", text: $searchText)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .onChange(of: searchText) { oldValue, newValue in
                            viewModel.filterAttractions(searchText: newValue)
                        }
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            viewModel.filterAttractions(searchText: "")
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(themeManager.selectedTheme.secondaryColor)
                        }
                    }
                }
                .padding()
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(themeManager.selectedTheme.backgroundColor)
                )
                .padding(.horizontal)
                
                // Results
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

                        Divider()
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}
