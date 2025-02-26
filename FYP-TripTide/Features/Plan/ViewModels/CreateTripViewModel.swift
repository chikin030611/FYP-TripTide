import Foundation

class CreateTripViewModel: ObservableObject {
    @Published var trip: Trip

    init() {
        // Initialize with nil dates - they will be set when user selects them
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        
        self.trip = Trip(
            id: UUID().uuidString,  // Generate a proper UUID
            name: "",
            description: "",
            startDate: startOfToday,
            endDate: startOfToday
        )
    }

    func createTrip() {
        // Convert dates to user's timezone for display
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        print("Creating trip: \(trip.name)")
        print("Description: \(trip.description)")
        print("Start date (local): \(formatter.string(from: trip.startDate))")
        print("End date (local): \(formatter.string(from: trip.endDate))")
    }

}
