import Foundation

struct DailyItinerary: Identifiable, Codable {
    var id: String
    var tripId: String
    var dayNumber: Int
    var notes: String?
    var places: [ScheduledPlace]
    
    init(id: String = UUID().uuidString,
         tripId: String,
         dayNumber: Int,
         notes: String? = nil,
         places: [ScheduledPlace] = []) {
        self.id = id
        self.tripId = tripId
        self.dayNumber = dayNumber
        self.notes = notes
        self.places = places
    }
}
