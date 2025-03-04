import Foundation

class EditTripViewModel: ObservableObject {
    @Published var trip: Trip
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private let originalTrip: Trip
    private let tripsAPI = TripsAPIController.shared

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
    
    @MainActor
    func updateTrip() async throws {
        isLoading = true
        error = nil
        
        do {
            try await tripsAPI.updateTrip(trip)
            isLoading = false
        } catch {
            isLoading = false
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
                throw apiError
            } else {
                self.error = error.localizedDescription
                throw error
            }
        }
    }

    @MainActor
    func deleteTrip() {
        isLoading = true
        error = nil
        
        Task {
            do {
                try await tripsAPI.deleteTrip(id: trip.id)
                isLoading = false
            } catch {
                if let apiError = error as? APIError {
                    self.error = apiError.localizedDescription
                } else {
                    self.error = error.localizedDescription
                }
                isLoading = false
            }
        }
    }
}
