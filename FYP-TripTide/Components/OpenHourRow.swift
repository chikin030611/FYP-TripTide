//
//  OpenHourRow.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 4/11/2024.
//

import SwiftUI

struct OpenHourRow: View {
    
    @StateObject var themeManager = ThemeManager()
    
    var openHour: OpenHour
//    let currentDate = Date()
    
    private var isOpen: Bool {
        // If the place is closed on the current day, return false
        if openHour.isRestDay {
            return false
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        // Create DateComponents for opening and closing times
        guard let openHH = openHour.getOpenTimeHour(),
              let openMinute = openHour.getOpenTimeMinute(),
              let closeHour = openHour.getCloseTimeHour(),
              let closeMinute = openHour.getCloseTimeMinute() else {
            return false // Assume closed if time details are missing
        }
        
        var openingTime = DateComponents()
        openingTime.hour = openHH
        openingTime.minute = openMinute
        
        var closingTime = DateComponents()
        closingTime.hour = closeHour
        closingTime.minute = closeMinute
        
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
        HStack {
            VStack(alignment: .leading) {
                
                // Display open or closed status
                Text(isOpen ? "Open Now" : "Closed Now")
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .foregroundStyle(isOpen ? themeManager.selectedTheme.accentColor : themeManager.selectedTheme.warningColor)
                
                HStack {
                    Text(openHour.day)
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
    OpenHourRow(openHour: OpenHour(day: "Monday", openTime: "10:00", closeTime: "20:00"))
//    OpenHourRow(openHour: OpenHour(day: "Sunday", openTime: "01:00", closeTime: "20:00"))
//    OpenHourRow(openHour: OpenHour(day: "Sunday", openTime: nil, closeTime: nil))
}
