import SwiftUI

class FilterViewModel: ObservableObject {
    @Published var selectedTags: Set<Tag> = []
    @Published var touristAttractionOptions: [Tag] = []
    @Published var restaurantOptions: [Tag] = []
    @Published var lodgingOptions: [Tag] = []
    
    func loadTags() async {
        print("Starting to load tags...")
        do {
            async let attractions = PlacesAPIController.shared.fetchTags(type: "tourist_attraction")
            async let restaurants = PlacesAPIController.shared.fetchTags(type: "restaurant")
            async let lodging = PlacesAPIController.shared.fetchTags(type: "lodging")
            
            print("Awaiting tag responses...")
            let (attractionTags, restaurantTags, lodgingTags) = await (try attractions, try restaurants, try lodging)
            
            await MainActor.run {
                self.touristAttractionOptions = attractionTags
                self.restaurantOptions = restaurantTags
                self.lodgingOptions = lodgingTags
                print("Tags set on main actor")
            }

            print("Tags loaded: \nAttractions: \(attractionTags)\nRestaurants: \(restaurantTags)\nLodging: \(lodgingTags)")
        } catch {
            print("Error fetching tags: \(error)")
        }
    }
    
    func toggleTag(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
} 