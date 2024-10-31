//
//  ThemeManager.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 31/10/2024.
//

import SwiftUI
/**
 Protocol for themes
 */
protocol ThemeProtocol {
    var largeTitleFont: Font { get }
    var textTitleFont: Font { get }
    var normalTitleFont: Font { get }
    var boldBtnTitleFont: Font { get }
    var bodyTextFont: Font { get }
    var captionTxtFont: Font { get }
    
    var accentColor: Color { get }
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var teritaryColor: Color { get }
    var btnTextColor: Color { get }
}

struct Main: ThemeProtocol {
    var largeTitleFont: Font { .system(size: 30, weight: .bold, design: .default) }
    var textTitleFont: Font { .system(size: 24, weight: .medium, design: .default) }
    var normalTitleFont: Font { .system(size: 20, weight: .semibold, design: .default) }
    var boldBtnTitleFont: Font { .system(size: 20, weight: .bold, design: .default) }
    var bodyTextFont: Font { .system(size: 18, weight: .regular, design: .default) }
    var captionTxtFont: Font { .system(size: 16, weight: .regular, design: .default) }
    
    var accentColor: Color { return Color("mnAccentColor") }
    var primaryColor: Color { return Color("mnPrimaryColor") }
    var secondaryColor: Color { return Color("mnSecondaryColor") }
    var teritaryColor: Color { return Color("mnTeritaryColor") }
    var btnTextColor: Color { return Color("mnBtnTextColor") }
}

class ThemeManager: ObservableObject {
    @Published var selectedTheme: ThemeProtocol = Main()
    
    func setTheme(_ theme: ThemeProtocol) {
        selectedTheme = theme
    }
}


struct StylesDisplayer: View {
    
    @StateObject var themeManager = ThemeManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Large Title Font")
                    .font(themeManager.selectedTheme.largeTitleFont)
                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                
                Text("Text Title Font")
                    .font(themeManager.selectedTheme.textTitleFont)
                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                
                Text("Normal Button Title Font")
                    .font(themeManager.selectedTheme.normalTitleFont)
                    .foregroundColor(themeManager.selectedTheme.accentColor)
                
                Text("Bold Button Title Font")
                    .font(themeManager.selectedTheme.boldBtnTitleFont)
                    .foregroundColor(themeManager.selectedTheme.accentColor)
                
                Text("Body Text Font")
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                
                Text("Caption Text Font")
                    .font(themeManager.selectedTheme.captionTxtFont)
                    .foregroundColor(themeManager.selectedTheme.teritaryColor)
                
                Button("Primary Button") {
                    print("Primary button tapped")
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Secondary Button") {
                    print("Secondary button tapped")
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Tertiary Button") {
                    print("Tertiary button tapped")
                }
                .buttonStyle(TertiaryButtonStyle())
                
                Button("Quaternary Button") {
                    print("Quaternary button tapped")
                }
                .buttonStyle(QuaternaryButtonStyle())
                
                Button("Add") {
                    print("Add button tapped")
                }
                .buttonStyle(AddButtonStyle())
                
                Button("Remove") {
                    print("Remove button tapped")
                }
                .buttonStyle(RemoveButtonStyle())
                
                Button("Central and Western") {
                    print("Tag button tapped")
                }
                .buttonStyle(TagButtonStyle())
                
                Button("Eastern") {
                    print("Remove tag button tapped")
                }
                .buttonStyle(RemoveTagButtonStyle())
                
                TextField("Email Address", text: .constant(""))
                    .textFieldStyle(UnderlinedTextFieldStyle(icon: Image(systemName: "envelope")))
                
                SecureField("Password", text: .constant(""))
                    .textFieldStyle(UnderlinedTextFieldStyle(icon: Image(systemName: "lock")))
                
                Button("Login") {
                    print("Login button tapped")
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    StylesDisplayer()
}
