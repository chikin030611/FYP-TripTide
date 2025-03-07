import Foundation

class EditTripViewModel: ObservableObject {
    @Published var trip: Trip
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    
    private let originalTrip: Trip

    init(trip: Trip) {
        self.trip = trip
        self.originalTrip = trip
        self.startDate = trip.startDate
        self.endDate = trip.endDate
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
    
    func hasChanges() -> Bool {
        return trip.name != originalTrip.name ||
               trip.description != originalTrip.description ||
               startDate != originalTrip.startDate ||
               endDate != originalTrip.endDate
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
    
    @MainActor
    func updateTrip() async throws {
        guard validateForm() else { return }
        
        do {
            try await TripsManager.shared.updateTrip(trip)
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }

    @MainActor
    func deleteTrip() async {
        do {
            try await TripsManager.shared.deleteTrip(id: trip.id)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
