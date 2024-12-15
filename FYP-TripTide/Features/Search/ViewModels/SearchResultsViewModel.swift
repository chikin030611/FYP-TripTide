import Foundation

class SearchResultsViewModel: ObservableObject {
    @Published var searchResults: [Attraction] = []
    
    init() {
        // Load initial data
        searchResults = getAllAttractions()
    }
    
    func filterAttractions(searchText: String) {
        if searchText.isEmpty {
            searchResults = getAllAttractions()
        } else {
            searchResults = getAllAttractions().filter { attraction in
                attraction.name.localizedCaseInsensitiveContains(searchText) ||
                attraction.tags.contains { tag in
                    tag.name.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    }
} 