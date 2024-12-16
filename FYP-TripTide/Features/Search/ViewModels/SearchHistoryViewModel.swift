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
        
        // Load recently viewed from UserDefaults
        let recentlyViewedIds = userDefaults.stringArray(forKey: recentlyViewedKey) ?? []
        self.recentlyViewedAttractions = recentlyViewedIds.compactMap { getAttraction(by: $0) }
        
        self.recentTags = [Tag(name: "Tag1"), Tag(name: "Tag2")]
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
