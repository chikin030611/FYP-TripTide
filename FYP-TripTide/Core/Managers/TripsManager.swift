import Foundation

class TripsManager: ObservableObject {
    @Published private(set) var trips: [Trip] = []
    @Published private(set) var isLoading = false
    @Published var error: String?
    
    static let shared = TripsManager()
    private let tripsAPI = TripsAPIController()
    
    private init() {}
    
    @MainActor
    func fetchTrips() async {
        isLoading = true
        error = nil
        
        do {
            trips = try await tripsAPI.fetchTrips()
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
            } else {
                self.error = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    @MainActor
    func createTrip(_ trip: Trip) async throws -> Trip {
        isLoading = true
        error = nil
        
        do {
            let newTrip = try await tripsAPI.createTrip(trip: trip)
            trips.append(newTrip)
            return newTrip
        } catch {   
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
                throw apiError
            } else {
                self.error = error.localizedDescription
                throw error
            }
        }
        isLoading = false
    }
    
    @MainActor
    func updateTrip(_ trip: Trip) async throws {
        isLoading = true
        error = nil
        
        do {
            try await tripsAPI.updateTrip(trip)
            if let index = trips.firstIndex(where: { $0.id == trip.id }) {
                trips[index] = trip
            }
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
                throw apiError
            } else {
                self.error = error.localizedDescription
                throw error
            }
        }
        isLoading = false
    }
    
    @MainActor
    func deleteTrip(id: String) async throws {
        isLoading = true
        error = nil
        
        do {
            try await tripsAPI.deleteTrip(id: id)
            trips.removeAll { $0.id == id }
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
                throw apiError
            } else {
                self.error = error.localizedDescription
                throw error
            }
        }
        isLoading = false
    }
    
    @MainActor
    func fetchTrip(id: String) async throws -> Trip? {
        isLoading = true
        error = nil
        
        do {
            let trip = try await tripsAPI.fetchTrip(id: id)
            if let trip = trip {
                if let index = trips.firstIndex(where: { $0.id == id }) {
                    trips[index] = trip
                }
            }
            return trip
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
                throw apiError
            } else {
                self.error = error.localizedDescription
                throw error
            }
        } 
        isLoading = false
    }
} 