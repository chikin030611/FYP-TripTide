import Foundation

class SearchHistoryViewModel: ObservableObject {
    @Published var recentTags: [String]
    @Published var recentlyViewedAttractions: [Attraction]
    
    init() {
        // Initialize with sample data - Later replace with actual data storage
        self.recentTags = [
            "Restaurant", "Hotel", "Beach", "Museum", 
            "Park", "Shopping", "Attraction", "Transport", 
            "Activity", "Nightlife"
        ]
        
        // Get attractions from IDs - Later implement proper data persistence
        let recentlyViewedIds = ["2", "3", "8"]
        self.recentlyViewedAttractions = recentlyViewedIds.compactMap { getAttraction(by: $0) }
    }
    
    // Add a tag to recent tags
    func addRecentTag(_ tag: String) {
        if !recentTags.contains(tag) {
            recentTags.insert(tag, at: 0)
            if recentTags.count > 10 {
                recentTags.removeLast()
            }
        }
    }
    
    // Add an attraction to recently viewed
    func addRecentlyViewed(_ attraction: Attraction) {
        if !recentlyViewedAttractions.contains(where: { $0.id == attraction.id }) {
            recentlyViewedAttractions.insert(attraction, at: 0)
            if recentlyViewedAttractions.count > 5 {
                recentlyViewedAttractions.removeLast()
            }
        }
    }
    
}
