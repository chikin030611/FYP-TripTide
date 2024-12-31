import SwiftUI

// First, create an environment key for the search action
private struct SearchActionKey: EnvironmentKey {
    static let defaultValue: (String) -> Void = { _ in }
}

extension EnvironmentValues {
    var onSearch: (String) -> Void {
        get { self[SearchActionKey.self] }
        set { self[SearchActionKey.self] = newValue }
    }
}

struct SearchHistoryView: View {
    @StateObject var themeManager = ThemeManager()
    @ObservedObject var viewModel: SearchHistoryViewModel
    @Environment(\.onSearch) private var onSearch
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Recent Searches
            VStack(alignment: .leading, spacing: 16) {
                Text("Recent Searches")
                    .font(themeManager.selectedTheme.boldTitleFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
                
                if !viewModel.recentSearches.isEmpty {
                    ForEach(viewModel.recentSearches, id: \.self) { search in
                        Button {
                            onSearch(search)
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
                                Text(search)
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                                    .padding(.leading, 8)
                                Spacer()
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Text("No recent searches")
                        .font(themeManager.selectedTheme.bodyTextFont)
                        .foregroundColor(themeManager.selectedTheme.secondaryColor)
                }
            }
            
            // Recently Viewed
            VStack(alignment: .leading, spacing: 16) {
                Text("Recently Viewed")
                    .font(themeManager.selectedTheme.boldTitleFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
                
                if !viewModel.recentlyViewedAttractions.isEmpty {
                    ForEach(viewModel.recentlyViewedAttractions) { attraction in
                        NavigationLink {
                            AttractionDetailView(attraction: attraction)
                        } label: {
                            SearchHistoryRow(attraction: attraction)
                        }
                    }
                } else {
                    Text("No recently viewed attractions")
                        .font(themeManager.selectedTheme.bodyTextFont)
                        .foregroundColor(themeManager.selectedTheme.secondaryColor)
                }
            }
        }
        .padding()
    }
}
