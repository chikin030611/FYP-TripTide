import SwiftUI

class FilterViewModel: ObservableObject {
    @Published var selectedTags: Set<Tag> = []
    
    let touristAttractionOptions = [
        Tag(name: "Museum"), Tag(name: "Park"), Tag(name: "Monument"), 
        Tag(name: "Historical Site"), Tag(name: "Art Gallery"), Tag(name: "Zoo"),
        Tag(name: "Aquarium"), Tag(name: "Theme Park"), Tag(name: "Water Park"),
        Tag(name: "Amusement Park"), Tag(name: "Zipline"), Tag(name: "Waterfall"),
        Tag(name: "Cave"), Tag(name: "Mountain"), Tag(name: "Beach"),
        Tag(name: "Island"), Tag(name: "Forest"), Tag(name: "Desert"),
        Tag(name: "Mountain Range"), Tag(name: "National Park"), 
        Tag(name: "National Forest"), Tag(name: "National Monument")
    ]
    
    let restaurantOptions = [
        Tag(name: "Restaurant"), Tag(name: "Cafe"), Tag(name: "Fast Food"),
        Tag(name: "Fine Dining"), Tag(name: "Bar"), Tag(name: "Pub"),
        Tag(name: "Bistro"), Tag(name: "Diner"), Tag(name: "Food Court"),
        Tag(name: "Food Truck"), Tag(name: "Food Festival"), Tag(name: "Food Market")
    ]
    
    let lodgingOptions = [
        Tag(name: "Hotel"), Tag(name: "Motel"), Tag(name: "Hostel"),
        Tag(name: "Resort"), Tag(name: "Apartment"), Tag(name: "B&B"),
        Tag(name: "Vacation Rental"), Tag(name: "Cottage"), Tag(name: "Villa"),
        Tag(name: "House")
    ]
    
    func toggleTag(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
} 