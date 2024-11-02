//
//  ImageCarousel.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 3/11/2024.
//

import SwiftUI

struct ImageCarousel: View {
    
    var images: [Image] = []
    
    var body: some View {
        VStack {
            TabView {
                ForEach(images.indices, id: \.self) { index in
                    images[index]
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width)
                        .clipped()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 250)
        }
    }
}
