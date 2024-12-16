//
//  StyleDisplayer.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 3/11/2024.
//

import SwiftUI

struct UITestView: View {
    @StateObject var themeManager = ThemeManager()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var images: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
//                TypographySection(themeManager: themeManager)
//                
//                Divider()
//                
//                CardView()
//                
//                Divider()
//                
//                CarouselSection(images: $images)
//                
//                Divider()
                
                FormInputSection(email: $email, password: $password)
                
                Divider()
                
                ButtonStylesSection()
            }
            .padding()
            .onAppear(perform: loadImages)
        }
        .onTapGesture {}
    }
}

// MARK: - Typography Section
struct TypographySection: View {
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        VStack {
            Text("Larger Title Font")
                .font(themeManager.selectedTheme.largerTitleFont)
                .foregroundColor(themeManager.selectedTheme.primaryColor)
            Text("Large Title Font")
                .font(themeManager.selectedTheme.largeTitleFont)
                .foregroundColor(themeManager.selectedTheme.primaryColor)
            Text("Normal Title Font")
                .font(themeManager.selectedTheme.titleFont)
                .foregroundColor(themeManager.selectedTheme.accentColor)
            Text("Bold Title Font")
                .font(themeManager.selectedTheme.boldTitleFont)
                .foregroundColor(themeManager.selectedTheme.accentColor)
            Text("Body Text Font")
                .font(themeManager.selectedTheme.bodyTextFont)
                .foregroundColor(themeManager.selectedTheme.primaryColor)
            Text("Caption Text Font")
                .font(themeManager.selectedTheme.captionTextFont)
                .foregroundColor(themeManager.selectedTheme.teritaryColor)
        }
    }
}

// MARK: - Card Section
struct CardView: View {
    @State private var cards: [Card] = [
        Card(attractionId: "1"),
        Card(attractionId: "2"),
        Card(attractionId: "3"),
        Card(attractionId: "4"),
        Card(attractionId: "5"),
        Card(attractionId: "6")
    ]

    var body: some View {
        CardGroup(cards: cards, style: .regular)
        
        Card(attractionId: "7")
            .padding(.vertical, 10)
    }
}

// MARK: - Carousel Section
struct CarouselSection: View {
    @Binding var images: [String]

    var body: some View {
        ImageCarousel(images: images)
            .frame(height: 200)
            .padding(.vertical, 10)
    }
}

// MARK: - Form Input Section
struct FormInputSection: View {
    @Binding var email: String
    @Binding var password: String

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Email Address", text: $email)
                .textFieldStyle(UnderlinedTextFieldStyle(icon: Image(systemName: "envelope")))
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(UnderlinedTextFieldStyle(icon: Image(systemName: "lock")))
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Button Styles Section
struct ButtonStylesSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Button("Primary Button") { print("Primary button tapped") }
                .buttonStyle(PrimaryButtonStyle())
            Button("Secondary Button") { print("Secondary button tapped") }
                .buttonStyle(SecondaryButtonStyle())
            Button("Tertiary Button") { print("Tertiary button tapped") }
                .buttonStyle(TertiaryButtonStyle())
            Button("Quaternary Button") { print("Quaternary button tapped") }
                .buttonStyle(QuaternaryButtonStyle())
            Button("Add") { print("Add button tapped") }
                .buttonStyle(AddButtonStyle())
            Button("Remove") { print("Remove button tapped") }
                .buttonStyle(RemoveButtonStyle())
            Button("Central and Western") { print("Tag button tapped") }
                .buttonStyle(TagButtonStyle())
            Button("Eastern") { print("Remove tag button tapped") }
                .buttonStyle(RemoveTagButtonStyle())
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Image Loading Function
extension UITestView {
    private func loadImages() {
        images = [
            "https://dummyimage.com/600x400.png/123/fff",
            "https://dummyimage.com/1080x1999.png/000/fff",
            "https://dummyimage.com/600x400.png/2d39d6/fff",
            "https://dummyimage.com/600x400.png/fff/000"
        ]
    }
}

#Preview {
    UITestView()
}
