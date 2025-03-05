import Foundation

class CreateTripViewModel: ObservableObject {
    @Published var trip: Trip
    @Published var tripCreated = false
    private let tripsAPI = TripsAPIController.shared

    init() {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        self.trip = Trip(
            id: UUID().uuidString,
            userId: "1",
            name: "",
            description: "",
            touristAttractionsIds: [],
            restaurantsIds: [],
            lodgingsIds: [],
            startDate: startOfToday,
            endDate: startOfToday
        )
    }

    func createTrip() async {
        // Ensure dates are set before creating trip
        guard trip.startDate != nil && trip.endDate != nil else {
            print("Error: Dates are required")
            return
        }
        
        do {
            let newTrip = try await tripsAPI.createTrip(trip: trip)
            trip = newTrip
            tripCreated = true
        } catch {
            print("Error creating trip: \(error)")
            tripCreated = false
        }
    }
}
