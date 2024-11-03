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
    @State private var images: [Image] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                TypographySection(themeManager: themeManager)
                
                Divider()
                
                CardView()
                
                Divider()
                
                CarouselSection(images: $images)
                
                Divider()
                
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
                .font(themeManager.selectedTheme.captionTextFont)
                .foregroundColor(themeManager.selectedTheme.teritaryColor)
        }
    }
}

// MARK: - Card Section
struct CardView: View {
    @State private var cards: [Card] = [
        Card(image: Image("test_light"), title: "Test1"),
        Card(image: Image("test_dark"), title: "Test2"),
        Card(image: Image("test_light"), title: "Test1"),
        Card(image: Image("test_dark"), title: "Test2"),
        Card(image: Image("test_light"), title: "Test1"),
        Card(image: Image("test_dark"), title: "Test2")
    ]

    var body: some View {
        CardGroup(cards: cards)
        
        Card(image: Image("test_light"), title: "Test")
            .padding(.vertical, 10)
    }
}

// MARK: - Carousel Section
struct CarouselSection: View {
    @Binding var images: [Image]

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
        let urls = [
            URL(string: "https://dummyimage.com/600x400.png/123/fff")!,
            URL(string: "https://dummyimage.com/1080x1999.png/000/fff")!,
            URL(string: "https://dummyimage.com/600x400.png/2d39d6/fff")!,
            URL(string: "https://dummyimage.com/600x400.png/fff/000")!
        ]

        for url in urls {
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else {
                    print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                if let uiImage = UIImage(data: data) {
                    let image = Image(uiImage: uiImage)
                    DispatchQueue.main.async {
                        self.images.append(image)
                    }
                }
            }.resume()
        }
    }
}

#Preview {
    UITestView()
}
