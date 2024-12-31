//
//  ImageCarousel.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 3/11/2024.
//

import SwiftUI

/** Image Carousel **/
struct ImageCarousel: View {
    
    let images: [String]
    
    var body: some View {
        TabView {
            ForEach(images.indices, id: \.self) { index in
                AsyncImageView(imageUrl: images[index])
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .frame(height: 200)
        .cornerRadius(10)
    }
}
