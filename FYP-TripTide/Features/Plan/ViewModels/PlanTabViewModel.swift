import Foundation

class PlanTabViewModel: ObservableObject {
    @Published var trips: [Trip] = []

    init() {
        self.trips = [
            Trip(
                id: "1",
                name: "Trip to Tokyo",
                description: "A trip to Tokyo",
                touristAttractions: [],
                restaurants: [],
                lodgings: [],
                startDate: Date(),
                endDate: Date()
            )
        ]
    }
    
    
}
