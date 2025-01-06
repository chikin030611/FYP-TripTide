import Foundation

class SearchHistoryViewModel: ObservableObject {
    @Published var recentSearches: [String] = []
    @Published var recentTags: [Tag]
    @Published var recentlyViewedAttractions: [Attraction]
    
    private let userDefaults = UserDefaults.standard
    private let recentSearchesKey = "recentSearches"
    private let recentlyViewedKey = "recentlyViewed"
    private let maxRecentSearches = 5
    private let maxRecentlyViewed = 5
    
    init() {
        // Load recent searches from UserDefaults
        self.recentSearches = userDefaults.stringArray(forKey: recentSearchesKey) ?? []
        self.recentlyViewedAttractions = []  // Initialize empty, will be loaded async
        self.recentTags = [Tag(name: "Tag1"), Tag(name: "Tag2")]
        
        // Load recently viewed attractions asynchronously
        Task {
            await loadRecentlyViewed()
        }
    }
    
    @MainActor
    private func loadRecentlyViewed() async {
        let recentlyViewedIds = userDefaults.stringArray(forKey: recentlyViewedKey) ?? []
        var loadedAttractions: [Attraction] = []
        
        for id in recentlyViewedIds {
            if let attraction = await getAttraction(by: id) {
                loadedAttractions.append(attraction)
            }
        }
        
        self.recentlyViewedAttractions = loadedAttractions
    }
    
    private func getAttraction(by id: String) async -> Attraction? {
        do {
            let placeDetail = try await PlacesAPIController.shared.fetchPlaceDetail(id: id)
            return placeDetail.toAttraction()
        } catch {
            print("Error fetching attraction details: \(error)")
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
    
    // Add an attraction to recently viewed
    func addRecentlyViewed(_ attraction: Attraction) {
        if !recentlyViewedAttractions.contains(where: { $0.id == attraction.id }) {
            recentlyViewedAttractions.insert(attraction, at: 0)
            if recentlyViewedAttractions.count > maxRecentlyViewed {
                recentlyViewedAttractions.removeLast()
            }
            
            // Save IDs to UserDefaults
            let attractionIds = recentlyViewedAttractions.map { $0.id }
            userDefaults.set(attractionIds, forKey: recentlyViewedKey)
        }
    }
    
}
