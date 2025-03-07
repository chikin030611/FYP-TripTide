import Foundation

@MainActor
class SearchResultsViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var currentSearchText: String = ""
    @Published var isLoading = false
    @Published var error: Error?
    @Published var hasMoreResults = true
    @Published var currentPage = 0
    @Published var currentTags: [String] = []

    let searchHistoryViewModel: SearchHistoryViewModel
    
    init(searchHistoryViewModel: SearchHistoryViewModel) {
        self.searchHistoryViewModel = searchHistoryViewModel
    }
    
    func addRecentlyViewed(_ place: Place) {
        searchHistoryViewModel.addRecentlyViewed(place)
    }
    
    @MainActor
    func filterPlaces(searchText: String, tags: [String] = []) async {
        isLoading = true
        defer { isLoading = false }
        
        // Reset pagination and store current search params
        currentSearchText = searchText
        currentTags = tags
        currentPage = 0
        
        do {
            let results = try await PlacesService.shared.searchPlaces(
                name: searchText,
                tags: tags,
                page: currentPage
            )
            self.places = results.map { $0.toPlace() }
            
            // Update pagination state
            hasMoreResults = !results.isEmpty
            if hasMoreResults {
                currentPage += 1
            }
        } catch {
            print("Error fetching places: \(error)")
            self.places = []
        }
    }
    
    func loadNextPage() async {
        guard !isLoading && hasMoreResults else { return }
        await loadNextPage(searchText: currentSearchText, tags: currentTags)
    }
    
    private func loadNextPage(searchText: String, tags: [String]) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let places = try await PlacesService.shared.searchPlaces(name: searchText, tags: tags, page: currentPage)
            
            // If we're on page 0, replace results. Otherwise, append.
            if currentPage == 0 {
                self.places = places.map { $0.toPlace() }
            } else {
                self.places.append(contentsOf: places.map { $0.toPlace() })
            }
            
            // Update pagination state
            hasMoreResults = !places.isEmpty
            if hasMoreResults {
                currentPage += 1
            }
        } catch {
            self.error = error
            if currentPage == 0 {
                self.places = []
            }
        }
    }
} 