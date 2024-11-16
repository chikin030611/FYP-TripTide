//
//  Models.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 16/11/2024.
//

import Foundation

struct Tag: Equatable {
    var name: String
}

struct OpenHour {
    var day: String
    var openTime: String?
    var closeTime: String?
    
    func getOpenTimeHour() -> Int? {
        guard let openTime = openTime else { return nil }
        return OpenHour.convertTimeToHour(time: openTime)
    }
    
    func getCloseTimeHour() -> Int? {
        guard let closeTime = closeTime else { return nil }
        return OpenHour.convertTimeToHour(time: closeTime)
    }
    
    static func convertTimeToHour(time: String) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // 24-hour time format
        
        let date = formatter.date(from: time)
        
        let calendar = Calendar.current
        return calendar.component(.hour, from: date!)
    }
    
    func getOpenTimeMinute() -> Int? {
        guard let openTime = openTime else { return nil }
        return OpenHour.convertTimeToMinute(time: openTime)
    }
    
    func getCloseTimeMinute() -> Int? {
        guard let closeTime = closeTime else { return nil }
        return OpenHour.convertTimeToMinute(time: closeTime)
    }
    
    static func convertTimeToMinute(time: String) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // 24-hour time format
        
        let date = formatter.date(from: time)
        
        let calendar = Calendar.current
        return calendar.component(.minute, from: date!)
    }
    
//    func getOpenTimeDate() -> Date? {
//        guard let openTime = openTime else { return nil }
//        return OpenHour.convertTimeToDate(time: openTime)
//    }
//    
//    func getCloseTimeDate() -> Date? {
//        guard let closeTime = closeTime else { return nil }
//        return OpenHour.convertTimeToDate(time: closeTime)
//    }
//    
//    static func convertTimeToDate(time: String) -> Date? {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm" // 24-hour time format
//        
//        formatter.timeZone = TimeZone(identifier: "Europe/London")
//        
//        
//        return formatter.date(from: time)
//    }
    
    var isRestDay: Bool {
        return openTime == nil || closeTime == nil
    }
}


struct Place: Identifiable {
    var id = UUID()
    var images: [String]
    var name: String
    var rating: Int
    var price: String
    var tags: [Tag]
    var openHours: [OpenHour]
    var stayingTime: String
    var description: String
    var latitude: Double
    var longitude: Double
}
