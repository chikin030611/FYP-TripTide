import Foundation

class PlanTabViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var isAuthenticated: Bool
    
    private let tripsManager = TripsManager.shared
    private let authManager = AuthManager.shared
    
    @MainActor
    init() {
        isAuthenticated = authManager.isAuthenticated
    }

    @MainActor
    func fetchTrips() {
        Task {
            await tripsManager.fetchTrips()
            self.trips = tripsManager.trips
            self.isLoading = tripsManager.isLoading
            self.error = tripsManager.error
        }
    }
}
