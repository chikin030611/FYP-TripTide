import Foundation

class CreateTripViewModel: ObservableObject {
    @Published var trip: Trip
    @Published var tripCreated = false
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var toastMessage: String = ""
    @Published var showToast: Bool = false
    
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

    var dateRangeToHighlight: ClosedRange<Date>? {
        guard let start = startDate, let end = endDate else { return nil }
        return start <= end ? start...end : end...start
    }

    func updateStartDate(_ date: Date?) {
        if let date = date {
            // Standardize to start of day in user's timezone
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            startDate = date
            trip.startDate = startOfDay
        }
    }

    func updateEndDate(_ date: Date?) {
        if let date = date {
            // Standardize to end of day in user's timezone
            let calendar = Calendar.current
            if let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date) {
                endDate = date
                trip.endDate = endOfDay
            }
        }
    }

    func validateForm() -> Bool {
        if trip.name.isEmpty {
            toastMessage = "Please enter a name for your trip."
            showToast = true
            return false
        }
        
        if startDate == nil || endDate == nil {
            toastMessage = "Please select both start and end dates."
            showToast = true
            return false
        }
        
        if let start = startDate, let end = endDate, start > end {
            toastMessage = "End date must be after start date."
            showToast = true
            return false
        }
        
        return true
    }

    func createTrip() async {
        do {
            let newTrip = try await tripsAPI.createTrip(trip: trip)
            trip = newTrip
            tripCreated = true
        } catch {
            print("Error creating trip: \(error)")
            tripCreated = false
        }
    }

    func hasChanges() -> Bool {
        return !trip.name.isEmpty || 
               !trip.description.isEmpty || 
               startDate != nil || 
               endDate != nil
    }
}
