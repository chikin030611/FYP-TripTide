import Foundation

class PlanTabViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private let tripsAPI = TripsAPIController.shared
    
    @MainActor
    func fetchTrips() {
        isLoading = true
        error = nil
        
        Task {
            do {
                trips = try await tripsAPI.fetchTrips()
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
