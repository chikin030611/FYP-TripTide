import Foundation

@MainActor
class SearchResultsViewModel: ObservableObject {
    @Published var searchResults: [Place] = []
    @Published var currentSearchText: String = ""
    @Published var isLoading = false
    @Published var error: Error?
    @Published var hasMoreResults = true
    @Published var currentPage = 0

    let searchHistoryViewModel: SearchHistoryViewModel
    
    init(searchHistoryViewModel: SearchHistoryViewModel) {
        self.searchHistoryViewModel = searchHistoryViewModel
    }
    
    func addRecentlyViewed(_ place: Place) {
        searchHistoryViewModel.addRecentlyViewed(place)
    }
    
    func filterPlaces(searchText: String) async {
        currentSearchText = searchText
        currentPage = 0 // Reset page when new search starts
        
        if searchText.isEmpty {
            searchResults = []  // Return to empty state to show history
            hasMoreResults = true
            return
        }
        
        await loadNextPage(searchText: searchText)
    }
    
    func loadNextPage() async {
        guard !isLoading && hasMoreResults else { return }
        await loadNextPage(searchText: currentSearchText)
    }
    
    private func loadNextPage(searchText: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let places = try await PlacesAPIController.shared.searchPlaces(name: searchText, page: currentPage)
            
            // If we're on page 0, replace results. Otherwise, append.
            if currentPage == 0 {
                searchResults = places.map { $0.toPlace() }
            } else {
                searchResults.append(contentsOf: places.map { $0.toPlace() })
            }
            
            // Update pagination state
            hasMoreResults = !places.isEmpty
            if hasMoreResults {
                currentPage += 1
            }
        } catch {
            self.error = error
            if currentPage == 0 {
                searchResults = []
            }
        }
    }
} 