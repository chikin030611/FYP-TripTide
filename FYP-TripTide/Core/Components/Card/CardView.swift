//
//  Card.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 3/11/2024.
//

import SwiftUI


struct Card: View {
    
    @StateObject var themeManager = ThemeManager()
    
    var attractionId: String
    @State private var attraction: Attraction
    
    init(attractionId: String) {
        self.attractionId = attractionId
        let initialAttraction = getAttraction(by: attractionId) ?? Attraction.empty
        _attraction = State(initialValue: initialAttraction)
    }
    
    var body: some View {
        NavigationLink(destination: AttractionDetailView(attraction: attraction)) {
            ZStack {
                if attraction.images.isEmpty {
                    // Fallback for when there are no images
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(width: 200, height: 150)
                } else {
                    AsyncImage(url: URL(string: attraction.images[0])) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure(_):
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                        @unknown default:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 200, height: 150)
                    .clipped()
                }
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.01), Color.gray]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // TODO: Make the text align
                Text(attraction.name)
                    .font(themeManager.selectedTheme.titleFont)
                    .foregroundColor(.white)
                    .frame(width: 180, height: 130, alignment: .bottomLeading)
            }
            .frame(width: 200, height: 150)
            .cornerRadius(10)
        }
    }
}

// #Preview {
//     Card(image: Image("test_light"), title: "Test")
// }
