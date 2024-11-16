//
//  OpenHourRow.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 4/11/2024.
//

import SwiftUI

struct OpenHourRow: View {
    
    @StateObject var themeManager = ThemeManager()
    
    var body: some View {
        HStack {
            
            // TODO: if open hour is now, show awccent color, else warning color
            VStack {
                Text("Open Now")
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .foregroundStyle(themeManager.selectedTheme.warningColor)
                
                Text("10:00 - 20:00")
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
//                .font(.title2)
                .foregroundStyle(themeManager.selectedTheme.secondaryColor)
            
        }
        .listStyle(.plain)
    }
}

#Preview {
    OpenHourRow()
}
