//
//  Card.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 3/11/2024.
//

import SwiftUI

struct CardGroup: View {
    @State var cards: [Card]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(cards, id: \.title) { card in
                    card
                }
            }
        }
    }
}

struct Card: View {
    
    @StateObject var themeManager = ThemeManager()
    
    @State var image: Image
    @State var title: String
    
    var body: some View {
        ZStack {
            image
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 150)
                .clipped()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.01), Color.gray]),
                        startPoint: .center,
                        endPoint: .bottom
                   )
                )
            
            Text(title)
                .font(themeManager.selectedTheme.titleFont)
                .foregroundColor(.white)
                .frame(width: 180, height: 130, alignment: .bottomLeading)

        }
        .cornerRadius(10)
    }
}

#Preview {
    Card(image: Image("test_light"), title: "Test")
}
