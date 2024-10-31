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
        
        HStack {
            if (icon != nil) {
                icon
                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
                    .padding(.leading, 10)
                    .padding(.trailing, 20)
            }
            configuration
                .foregroundColor(themeManager.selectedTheme.secondaryColor)
        }
            .padding(10)
            .background(
                VStack {
                    Spacer()
                    Color(themeManager.selectedTheme.teritaryColor)
                        .frame(height: 1)
                }
                    .padding(.horizontal, 10)
            )
    }
}

