//
//  Card.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 3/11/2024.
//

import SwiftUI


struct Card: View {
    
    @StateObject var themeManager = ThemeManager()
    
    let attraction: Attraction
    
    init(attraction: Attraction) {
        self.attraction = attraction
    }
    
    var body: some View {
        NavigationLink(destination: AttractionDetailView(attraction: attraction)) {
            ZStack {
                AsyncImageView(imageUrl: attraction.images[0], width: 150, height: 130)
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.01), Color.gray]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                Text(attraction.name)
                    .font(themeManager.selectedTheme.boldBodyTextFont)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: 130, height: 110, alignment: .bottomLeading)
            }
            .frame(width: 150, height: 130)
            .cornerRadius(10)
        }
    }
}

// #Preview {
//     Card(image: Image("test_light"), title: "Test")
// }
