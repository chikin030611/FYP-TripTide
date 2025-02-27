import Foundation

class PlanTabViewModel: ObservableObject {
    @Published var trips: [Trip] = []

    init() {
        self.trips = [
            Trip.sampleTrip,
            Trip(
                id: "2",
                name: "Trip to Hong Kong",
                description: "A trip to Tokyo",
                touristAttractions: [],
                restaurants: [],
                lodgings: [],
                startDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!
            )
        ]
    }
    
    
}
