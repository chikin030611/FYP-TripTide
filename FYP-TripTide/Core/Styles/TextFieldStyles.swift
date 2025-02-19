//
//  TextFieldStyles.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 31/10/2024.
//

import SwiftUI

// MARK: - Underlined TextField Style
struct UnderlinedTextFieldStyle: TextFieldStyle {
    
    @StateObject var themeManager = ThemeManager()
    
    @State var icon: Image?
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        
        HStack(alignment: .center, spacing: 8) { // Adjust spacing as needed
            if let icon = icon {
                icon
                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
                    .frame(width: 20, height: 20, alignment: .center)
                    .padding(.horizontal, 20)
            }
            configuration
                .foregroundColor(themeManager.selectedTheme.primaryColor)
        }
        .padding(10)
        .background(
            VStack {
                Spacer()
                Color(themeManager.selectedTheme.secondaryColor)
                    .frame(height: 1)
            }
            .padding(.horizontal, 10)
        )
    }
}

