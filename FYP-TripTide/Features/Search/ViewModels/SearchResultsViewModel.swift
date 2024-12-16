import Foundation

class SearchResultsViewModel: ObservableObject {
    @Published var searchResults: [Attraction] = []
    @Published var currentSearchText: String = ""
    let searchHistoryViewModel: SearchHistoryViewModel
    
    private var allAttractions: [Attraction]
    
    init(searchHistoryViewModel: SearchHistoryViewModel = SearchHistoryViewModel()) {
        self.searchHistoryViewModel = searchHistoryViewModel
        self.allAttractions = getAllAttractions()
        self.searchResults = []
    }
    
    func filterAttractions(searchText: String) {
        currentSearchText = searchText
        if searchText.isEmpty {
            searchResults = []  // Return to empty state to show history
        } else {
            searchResults = allAttractions.filter { attraction in
                attraction.name.localizedCaseInsensitiveContains(searchText) ||
                attraction.tags.contains { tag in
                    tag.name.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    }
} 