import Foundation

class SearchHistoryViewModel: ObservableObject {
    @Published var recentSearches: [String] = []
    @Published var recentTags: [Tag]
    @Published var recentlyViewedPlaces: [Place]
    
    private let userDefaults = UserDefaults.standard
    private let recentSearchesKey = "recentSearches"
    private let recentlyViewedKey = "recentlyViewed"
    private let maxRecentSearches = 5
    private let maxRecentlyViewed = 5
    
    init() {
        // Load recent searches from UserDefaults
        self.recentSearches = userDefaults.stringArray(forKey: recentSearchesKey) ?? []
        self.recentlyViewedPlaces = []  // Initialize empty, will be loaded async
        self.recentTags = [Tag(name: "Tag1"), Tag(name: "Tag2")]
        
        // Load recently viewed places asynchronously
        Task {
            await loadRecentlyViewed()
        }
    }
    
    @MainActor
    private func loadRecentlyViewed() async {
        let recentlyViewedIds = userDefaults.stringArray(forKey: recentlyViewedKey) ?? []
        var loadedPlaces: [Place] = []
        
        for id in recentlyViewedIds {
            if let place = await getPlace(by: id) {
                loadedPlaces.append(place)
            }
        }
        
        self.recentlyViewedPlaces = loadedPlaces
    }
    
    private func getPlace(by id: String) async -> Place? {
        do {
            let placeDetail = try await PlacesAPIController.shared.fetchPlaceDetailById(id: id)
            return placeDetail.toPlace()
        } catch {
            print("Error fetching place details: \(error)")
            return nil
        }
    }
    
    func addRecentSearch(_ searchText: String) {
        let trimmedText = searchText.trimmingCharacters(in: .whitespaces)
        if !trimmedText.isEmpty {
            // Remove if already exists (to avoid duplicates)
            recentSearches.removeAll { $0 == trimmedText }
            // Add to beginning of array
            recentSearches.insert(trimmedText, at: 0)
            // Keep only maxRecentSearches items
            if recentSearches.count > maxRecentSearches {
                recentSearches.removeLast()
            }
            // Save to UserDefaults
            userDefaults.set(recentSearches, forKey: recentSearchesKey)
        }
    }
    
    // Add a tag to recent tags
    func addRecentTag(_ tag: Tag) {
        if !recentTags.contains(where: { $0.name == tag.name }) {
            recentTags.insert(tag, at: 0)
            if recentTags.count > 5 {
                recentTags.removeLast()
            }
        }
    }
    
    // Add an place to recently viewed
    func addRecentlyViewed(_ place: Place) {
        if !recentlyViewedPlaces.contains(where: { $0.id == place.id }) {
            recentlyViewedPlaces.insert(place, at: 0)
            if recentlyViewedPlaces.count > maxRecentlyViewed {
                recentlyViewedPlaces.removeLast()
            }
            
            // Save IDs to UserDefaults
            let placeIds = recentlyViewedPlaces.map { $0.id }
            userDefaults.set(placeIds, forKey: recentlyViewedKey)
        }
    }
    
}
