import Foundation

struct OpenHour {
    var weekdayIndex: Int
    var openTime: String?
    var closeTime: String?
    
    var isRestDay: Bool {
        return openTime == nil || closeTime == nil
    }
    
    func dayName() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.weekdaySymbols[weekdayIndex - 1]
    }
    
    func getOpenTimeHour() -> Int? {
        guard let openTime = openTime else { return nil }
        return OpenHour.convertTimeToHour(time: openTime)
    }
    
    func getOpenTimeMinute() -> Int? {
        guard let openTime = openTime else { return nil }
        return OpenHour.convertTimeToMinute(time: openTime)
    }
    
    func getCloseTimeHour() -> Int? {
        guard let closeTime = closeTime else { return nil }
        return OpenHour.convertTimeToHour(time: closeTime)
    }
    
    func getCloseTimeMinute() -> Int? {
        guard let closeTime = closeTime else { return nil }
        return OpenHour.convertTimeToMinute(time: closeTime)
    }
}

// MARK: - Time Conversion Helpers
extension OpenHour {
    static func convertTimeToHour(time: String) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let date = formatter.date(from: time) else {
            return nil
        }
        
        let calendar = Calendar.current
        return calendar.component(.hour, from: date)
    }

    static func convertTimeToMinute(time: String) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let date = formatter.date(from: time) else {
            return nil
        }
        
        let calendar = Calendar.current
        return calendar.component(.minute, from: date)
    }
} 