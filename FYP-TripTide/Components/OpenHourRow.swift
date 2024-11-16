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
        
        // Get the current hour and minute
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTotalMinutes = (currentHour * 60) + currentMinute

        // Get open and close hours and minutes
        guard let openHH = openHour.getOpenTimeHour(),
              let openMM = openHour.getOpenTimeMinute(),
              let closeHH = openHour.getCloseTimeHour(),
              let closeMM = openHour.getCloseTimeMinute() else {
            return false // If any value is missing, assume closed
        }

        // Calculate total minutes for open and close times
        let openTotalMinutes = (openHH * 60) + openMM
        let closeTotalMinutes = (closeHH * 60) + closeMM

        // Compare the total minutes
        return currentTotalMinutes >= openTotalMinutes && currentTotalMinutes <= closeTotalMinutes
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
//    OpenHourRow(openHour: OpenHour(day: "Monday", openTime: "10:00", closeTime: "20:00"))
    OpenHourRow(openHour: OpenHour(day: "Sunday", openTime: "01:00", closeTime: "20:00"))
//    OpenHourRow(openHour: OpenHour(day: "Sunday", openTime: nil, closeTime: nil))
}
