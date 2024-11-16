//
//  OpenHourRow.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 4/11/2024.
//

import SwiftUI


struct OpenHourRow: View {
    
    @StateObject var themeManager = ThemeManager()
    
    var openHours: [OpenHour]
//    let currentDate = Date()
    
    private var todayOpenHour: OpenHour? {
        let now = Date()
        let calendar = Calendar.current
        let todayIndex = calendar.component(.weekday, from: now) // 1 = Sunday, 7 = Saturday
        
        // Map weekday index to OpenHour day
        return openHours.first { $0.weekdayIndex == todayIndex }
    }
    
    private var isOpen: Bool {
        // If the place is closed on the current day, return false
        guard let openHour = todayOpenHour, !openHour.isRestDay else {
            return false
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        // Create DateComponents for opening and closing times
        guard let openHH = openHour.getOpenTimeHour(),
              let openMM = openHour.getOpenTimeMinute(),
              let closeHH = openHour.getCloseTimeHour(),
              let closeMM = openHour.getCloseTimeMinute() else {
            return false // Assume closed if time details are missing
        }
        
        var openingTime = DateComponents()
        openingTime.hour = openHH
        openingTime.minute = openMM
        
        var closingTime = DateComponents()
        closingTime.hour = closeHH
        closingTime.minute = closeMM
        
        // Convert to `Date`
        guard let openingDate = calendar.nextDate(after: now, matching: openingTime, matchingPolicy: .nextTime),
              let closingDate = calendar.nextDate(after: now, matching: closingTime, matchingPolicy: .nextTime) else {
            return false
        }
        
        // Handle spanning midnight by checking if the closing time is earlier than opening time
        if closingDate < openingDate {
            return now >= openingDate || now <= closingDate
        } else {
            return now >= openingDate && now <= closingDate
        }
    }

    
    var body: some View {
        // TODO: Add a button to show all open hours
        HStack {
            VStack(alignment: .leading) {
                
                // Display open or closed status
                Text(isOpen ? "Open Now" : "Closed Now")
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .foregroundStyle(isOpen ? themeManager.selectedTheme.accentColor : themeManager.selectedTheme.warningColor)
                
                HStack {
                    if let openHour = todayOpenHour {
                        Text(openHour.dayName())
                            .font(themeManager.selectedTheme.captionTextFont)
                            .foregroundStyle(themeManager.selectedTheme.primaryColor)
                        
                        Text("•")
                            .font(themeManager.selectedTheme.captionTextFont)
                        
                        if openHour.isRestDay {
                            Text("Rest Day")
                                .font(themeManager.selectedTheme.captionTextFont)
                                .foregroundStyle(themeManager.selectedTheme.primaryColor)
                        } else {
                            Text("\(openHour.openTime!) - \(openHour.closeTime!)")
                                .font(themeManager.selectedTheme.captionTextFont)
                                .foregroundStyle(themeManager.selectedTheme.primaryColor)
                        }
                    } else {
                        Text("No open hours available")
                            .font(themeManager.selectedTheme.captionTextFont)
                            .foregroundStyle(themeManager.selectedTheme.primaryColor)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(themeManager.selectedTheme.secondaryColor)
        }
        .listStyle(.plain)
    }
}

#Preview {
    OpenHourRow(openHours: [
        OpenHour(weekdayIndex: 2, openTime: "10:00 AM", closeTime: "8:00 PM"),
        OpenHour(weekdayIndex: 3, openTime: "10:00 AM", closeTime: "8:00 PM"),
        OpenHour(weekdayIndex: 4, openTime: "10:00 AM", closeTime: "8:00 PM"),
        OpenHour(weekdayIndex: 5, openTime: "10:00 AM", closeTime: "8:00 PM"),
        OpenHour(weekdayIndex: 6, openTime: "10:00 AM", closeTime: "8:00 PM"),
        OpenHour(weekdayIndex: 7, openTime: nil, closeTime: nil),
        OpenHour(weekdayIndex: 1, openTime: nil, closeTime: nil)
    ])
}
