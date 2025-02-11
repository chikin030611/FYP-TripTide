import SwiftUI

class FilterViewModel: ObservableObject {
    @Published var selectedTags: Set<Tag> = []
    @Published var touristAttractionOptions: [Tag] = []
    @Published var restaurantOptions: [Tag] = []
    @Published var lodgingOptions: [Tag] = []
    
    var onApplyAndSearchFilter: (([String]) -> Void)?
    
    func loadTags() async {
        do {
            async let attractions = PlacesAPIController.shared.fetchTags(type: "tourist_attraction")
            async let restaurants = PlacesAPIController.shared.fetchTags(type: "restaurant")
            async let lodging = PlacesAPIController.shared.fetchTags(type: "lodging")
            
            let (attractionTags, restaurantTags, lodgingTags) = await (try attractions, try restaurants, try lodging)
            
            await MainActor.run {
                self.touristAttractionOptions = attractionTags
                self.restaurantOptions = restaurantTags
                self.lodgingOptions = lodgingTags
            }

        } catch {
            print("Error fetching tags: \(error)")
        }
    }
    
    func toggleTag(_ tag: Tag) {
        if let index = selectedTags.firstIndex(where: { $0.name == tag.name }) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    func applyAndSearchFilters() {
        let selectedTagNames = Array(selectedTags).map { $0.name }
        onApplyAndSearchFilter?(selectedTagNames)
    }
} 