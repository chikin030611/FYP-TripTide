import Foundation

struct OpenHour {
    var weekdayIndex: Int
    var openTime: String?
    var closeTime: String?
    var isOpen24Hours: Bool
    
    var isRestDay: Bool {
        return !isOpen24Hours && (openTime == nil || closeTime == nil)
    }
    
    // Add initializer for Google Places API response
    init(from period: [String: Any]) {
        if let open = period["open"] as? [String: Any],
           let close = period["close"] as? [String: Any] {
            
            // Google uses 0-6 for Sunday-Saturday
            // We need to convert to 1-7 for Monday-Sunday
            let googleDay = open["day"] as? Int ?? 0
            self.weekdayIndex = (googleDay + 6) % 7 + 1
            
            // Check if it's a 24-hour operation
            let isTruncated = (open["truncated"] as? Bool) ?? false
            self.isOpen24Hours = isTruncated
            
            if isOpen24Hours {
                self.openTime = "00:00"
                self.closeTime = "24:00"
            } else {
                // Format time strings for normal operating hours
                if let openHour = open["hour"] as? Int,
                   let openMinute = open["minute"] as? Int {
                    self.openTime = String(format: "%02d:%02d", openHour, openMinute)
                }
                
                if let closeHour = close["hour"] as? Int,
                   let closeMinute = close["minute"] as? Int {
                    self.closeTime = String(format: "%02d:%02d", closeHour, closeMinute)
                }
            }
        } else {
            self.weekdayIndex = 1
            self.openTime = nil
            self.closeTime = nil
            self.isOpen24Hours = false
        }
    }
    
    // Keep existing initializer for other uses
    init(weekdayIndex: Int, openTime: String?, closeTime: String?, isOpen24Hours: Bool = false) {
        self.weekdayIndex = weekdayIndex
        self.openTime = openTime
        self.closeTime = closeTime
        self.isOpen24Hours = isOpen24Hours
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
    
    // Add static method to create OpenHours from Google Places API response
    static func createFromGooglePlaces(openingHours: [String: Any]) -> [OpenHour] {
        guard let periods = openingHours["periods"] as? [[String: Any]] else {
            return []
        }
        
        var openHours: [OpenHour] = []
        
        // Check if it's a 24/7 operation
        if periods.count == 1,
           let period = periods.first,
           let open = period["open"] as? [String: Any],
           (open["truncated"] as? Bool) == true {
            // Create 24-hour entries for all days
            for weekday in 1...7 {
                openHours.append(OpenHour(weekdayIndex: weekday, 
                                       openTime: "00:00",
                                       closeTime: "24:00",
                                       isOpen24Hours: true))
            }
        } else {
            // Normal operation - create OpenHour instances from periods
            for period in periods {
                let openHour = OpenHour(from: period)
                openHours.append(openHour)
            }
            
            // Fill in missing days as rest days
            for weekday in 1...7 {
                if !openHours.contains(where: { $0.weekdayIndex == weekday }) {
                    openHours.append(OpenHour(weekdayIndex: weekday,
                                           openTime: nil,
                                           closeTime: nil,
                                           isOpen24Hours: false))
                }
            }
        }
        
        return openHours.sorted(by: { $0.weekdayIndex < $1.weekdayIndex })
    }
}

extension Array where Element == OpenHour {
    static func from(_ apiHours: PlaceDetailResponse.OpeningHours) -> [OpenHour] {
        var openHours: [OpenHour] = []
        
        // Convert each period to OpenHour
        for period in apiHours.periods {
            // Google uses 0-6 for Sunday-Saturday
            // We need to convert to 1-7 for Monday-Sunday
            let googleDay = period.open.day
            let weekdayIndex = (googleDay + 6) % 7 + 1
            
            let openTime = String(format: "%02d:%02d", period.open.hour, period.open.minute)
            let closeTime = String(format: "%02d:%02d", period.close.hour, period.close.minute)
            
            // Check if it's a 24-hour operation
            let isOpen24Hours = openTime == "00:00" && closeTime == "24:00"
            
            openHours.append(OpenHour(
                weekdayIndex: weekdayIndex,
                openTime: openTime,
                closeTime: closeTime,
                isOpen24Hours: isOpen24Hours
            ))
        }
        
        // Fill in missing days as rest days
        for weekday in 1...7 {
            if !openHours.contains(where: { $0.weekdayIndex == weekday }) {
                openHours.append(OpenHour(
                    weekdayIndex: weekday,
                    openTime: nil,
                    closeTime: nil,
                    isOpen24Hours: false
                ))
            }
        }
        
        // Sort by weekday
        return openHours.sorted(by: { $0.weekdayIndex < $1.weekdayIndex })
    }
} 