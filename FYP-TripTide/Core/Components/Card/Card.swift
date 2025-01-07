//
//  Card.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 3/11/2024.
//

import SwiftUI


struct Card: View {
    
    @StateObject var themeManager = ThemeManager()
    
    let place: Place
    
    init(place: Place) {
        self.place = place
    }
    
    var body: some View {
        NavigationLink(destination: PlaceDetailView(place: place)) {
            ZStack {
                AsyncImageView(imageUrl: place.images[0], width: 150, height: 130)
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.01), Color.gray]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                Text(place.name)
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
