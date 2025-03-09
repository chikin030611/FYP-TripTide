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
    private var currentFetchTask: Task<Void, Never>?
    
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
        // Cancel any existing fetch task
        currentFetchTask?.cancel()
        
        // Create new task
        currentFetchTask = Task {
            // If already loading, wait a bit before trying again
            if isLoading {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                guard !Task.isCancelled else { return }
            }
            
            // Reset error state
            error = nil
            
            do {
                isLoading = true
                await tripsManager.fetchTrips()
                
                // Check if task was cancelled before updating UI
                guard !Task.isCancelled else { return }
                
                self.trips = tripsManager.trips
                self.error = nil
            } catch {
                // Only set error if task wasn't cancelled
                if !Task.isCancelled {
                    self.error = error.localizedDescription
                }
            }
            
            // Only update loading state if task wasn't cancelled
            if !Task.isCancelled {
                isLoading = false
            }
        }
    }
    
    deinit {
        currentFetchTask?.cancel()
    }
}
