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
    var captionTextFont: Font { get }
    
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
    var captionTextFont: Font { .system(size: 16, weight: .regular, design: .default) }
    
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
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var images: [Image] = []
    
    var body: some View {
        ScrollView {
            VStack() {
//                Text("Large Title Font")
//                    .font(themeManager.selectedTheme.largeTitleFont)
//                    .foregroundColor(themeManager.selectedTheme.primaryColor)
//                    .padding(.vertical, 10)
//                
//                Text("Text Title Font")
//                    .font(themeManager.selectedTheme.textTitleFont)
//                    .foregroundColor(themeManager.selectedTheme.primaryColor)
//                    .padding(.vertical, 10)
//                
//                Text("Normal Button Title Font")
//                    .font(themeManager.selectedTheme.normalTitleFont)
//                    .foregroundColor(themeManager.selectedTheme.accentColor)
//                    .padding(.vertical, 10)
//                
//                Text("Bold Button Title Font")
//                    .font(themeManager.selectedTheme.boldBtnTitleFont)
//                    .foregroundColor(themeManager.selectedTheme.accentColor)
//                    .padding(.vertical, 10)
//
//                Text("Body Text Font")
//                    .font(themeManager.selectedTheme.bodyTextFont)
//                    .foregroundColor(themeManager.selectedTheme.primaryColor)
//                    .padding(.vertical, 10)
//                
//                Text("Caption Text Font")
//                    .font(themeManager.selectedTheme.captionTxtFont)
//                    .foregroundColor(themeManager.selectedTheme.teritaryColor)
//                    .padding(.vertical, 10)
                
                Card(image: Image("test_light"), title: "Test")
                    .padding(.vertical, 10)
                
                Card(image: Image("test_dark"), title: "Test")
                    .padding(.vertical, 10)
                
                ImageCarousel(images: images)
                    .frame(height: 200)
                    .onAppear(perform: loadImages)
                
                TextField("Email Address", text: $email)
                    .textFieldStyle(UnderlinedTextFieldStyle(icon: Image(systemName: "envelope")))
                    .padding(.vertical, 10)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(UnderlinedTextFieldStyle(icon: Image(systemName: "lock")))
                    .padding(.vertical, 10)
                
                Button("Primary Button") {
                    print("Primary button tapped")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.vertical, 10)
                
                Button("Secondary Button") {
                    print("Secondary button tapped")
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding(.vertical, 10)
                
                Button("Tertiary Button") {
                    print("Tertiary button tapped")
                }
                .buttonStyle(TertiaryButtonStyle())
                .padding(.vertical, 10)
                
                Button("Quaternary Button") {
                    print("Quaternary button tapped")
                }
                .buttonStyle(QuaternaryButtonStyle())
                .padding(.vertical, 10)
                
                Button("Add") {
                    print("Add button tapped")
                }
                .buttonStyle(AddButtonStyle())
                .padding(.vertical, 10)
                
                Button("Remove") {
                    print("Remove button tapped")
                }
                .buttonStyle(RemoveButtonStyle())
                .padding(.vertical, 10)
                
                Button("Central and Western") {
                    print("Tag button tapped")
                }
                .buttonStyle(TagButtonStyle())
                .padding(.vertical, 10)
                
                Button("Eastern") {
                    print("Remove tag button tapped")
                }
                .buttonStyle(RemoveTagButtonStyle())
                .padding(.vertical, 10)
                
            }
        }
        .onTapGesture{}
    }
}

extension StylesDisplayer {
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
    StylesDisplayer()
}
