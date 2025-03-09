import Foundation
import Combine

@MainActor
class PlanTabViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var isAuthenticated: Bool = false
    
    private let tripsManager = TripsManager.shared
    private let authManager = AuthManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize with current auth state
        isAuthenticated = authManager.isAuthenticated
        
        // Observe auth state changes
        authManager.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isAuthenticated = self?.authManager.isAuthenticated ?? false
                if self?.isAuthenticated == true {
                    self?.fetchTrips()
                }
            }
            .store(in: &cancellables)
    }

    func fetchTrips() {
        Task {
            await tripsManager.fetchTrips()
            self.trips = tripsManager.trips
            self.isLoading = tripsManager.isLoading
            self.error = tripsManager.error
        }
    }
}
