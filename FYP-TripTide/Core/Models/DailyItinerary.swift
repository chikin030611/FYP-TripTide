import Foundation

struct DailyItinerary: Identifiable, Codable {
    var id: String
    var tripId: String
    var dayNumber: Int
    var date: Date?
    var notes: String?
    var places: [ScheduledPlace]
    
    init(id: String = UUID().uuidString,
         tripId: String,
         dayNumber: Int,
         date: Date? = nil,
         notes: String? = nil,
         places: [ScheduledPlace] = []) {
        self.id = id
        self.tripId = tripId
        self.dayNumber = dayNumber
        self.date = date
        self.notes = notes
        self.places = places
    }
}
