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

// MARK: - Underlined TextEditor Style
struct BoxedTextEditorStyle: ViewModifier {
    @StateObject var themeManager = ThemeManager()
    let placeholder: String
    @Binding var text: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topLeading) {
            content
                .foregroundColor(themeManager.selectedTheme.primaryColor)
                .padding(6)

            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(themeManager.selectedTheme.secondaryColor.opacity(0.5))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(themeManager.selectedTheme.secondaryColor, lineWidth: 1)
        )
    }
}

extension View {
    func textEditorStyle(_ style: BoxedTextEditorStyle) -> some View {
        modifier(style)
    }
    
    // Add a convenience method
    func boxedTextEditorStyle(text: Binding<String>, placeholder: String = "") -> some View {
        modifier(BoxedTextEditorStyle(placeholder: placeholder, text: text))
    }
}
