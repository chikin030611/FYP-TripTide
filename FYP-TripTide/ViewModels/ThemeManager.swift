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
    var largerTitleFont: Font { get }
    var largeTitleFont: Font { get }
    var titleFont: Font { get }
    var boldTitleFont: Font { get }
    var bodyTextFont: Font { get }
    var captionTextFont: Font { get }
    
    var accentColor: Color { get }
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var teritaryColor: Color { get }
    var btnTextColor: Color { get }
}

struct Main: ThemeProtocol {
    var largerTitleFont: Font { .system(size: 34, weight: .bold, design: .default) }
    var largeTitleFont: Font { .system(size: 28, weight: .semibold, design: .default) }
    var titleFont: Font { .system(size: 22, weight: .semibold, design: .default) }
    var boldTitleFont: Font { .system(size: 17, weight: .bold, design: .default) }
    var bodyTextFont: Font { .system(size: 17, weight: .regular, design: .default) }
    var captionTextFont: Font { .system(size: 13, weight: .regular, design: .default) }
    
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

