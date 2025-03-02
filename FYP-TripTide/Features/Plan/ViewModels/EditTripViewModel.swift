import Foundation

class EditTripViewModel: ObservableObject {
    @Published var trip: Trip
    private let originalTrip: Trip

    init(trip: Trip) {
        self.trip = trip
        self.originalTrip = trip
    }
    
    func hasChanges() -> Bool {
        return trip.name != originalTrip.name ||
               trip.description != originalTrip.description ||
               trip.startDate != originalTrip.startDate ||
               trip.endDate != originalTrip.endDate
    }
    
    func updateTrip() {
        // Here you would typically call your database service to update the trip
        print("Updating trip: \(trip.name)")
    }
}
