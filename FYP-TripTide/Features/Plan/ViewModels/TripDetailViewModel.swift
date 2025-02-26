import Foundation

class TripDetailViewModel: ObservableObject {
    @Published var trip: Trip

    init(trip: Trip) {
        self.trip = trip
    }
}