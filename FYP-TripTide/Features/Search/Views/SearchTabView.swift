import SwiftUI

struct SearchTabView: View {
    @StateObject private var viewModel = SearchTabViewModel()
    @StateObject private var themeManager = ThemeManager()
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
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.gray.opacity(0.1))
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
