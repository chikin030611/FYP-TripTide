import Foundation

class SearchResultsViewModel: ObservableObject {
    @Published var searchResults: [Attraction] = []
    @Published var currentSearchText: String = ""
    
    private var allAttractions: [Attraction]
    
    init() {
        // Store all attractions but don't show them initially
        self.allAttractions = getAllAttractions()
        self.searchResults = []  // Start with empty results
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