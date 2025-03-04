import Foundation

struct ScheduledPlace: Identifiable, Codable {
    var id: String
    var placeId: String
    var startTime: Date?
    var endTime: Date?
    var notes: String?
} 