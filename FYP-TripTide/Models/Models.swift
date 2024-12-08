//
//  Models.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 16/11/2024.
//

import Foundation

// MARK: - Attraction Model
struct Attraction: Identifiable {
    var id: String
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

extension Attraction {
    static let empty = Attraction(
        id: "",
        images: [],
        name: "",
        rating: 0,
        price: "",
        tags: [],
        openHours: [],
        stayingTime: "",
        description: "",
        latitude: 0,
        longitude: 0
    )
}

// MARK: - Tag Model
struct Tag: Equatable {
    var name: String
}

// MARK: - OpenHour Model
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
        return formatter.weekdaySymbols[weekdayIndex - 1] // Array is 0-based, weekdayIndex is 1-based
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
    
    static func convertTimeToHour(time: String) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // 24-hour time format
        
        guard let date = formatter.date(from: time) else {
            return nil // Return nil if the date conversion fails
        }
        
        let calendar = Calendar.current
        return calendar.component(.hour, from: date)
    }

    static func convertTimeToMinute(time: String) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // 24-hour time format
        
        guard let date = formatter.date(from: time) else {
            return nil // Return nil if the date conversion fails
        }
        
        let calendar = Calendar.current
        return calendar.component(.minute, from: date)
    }
}


