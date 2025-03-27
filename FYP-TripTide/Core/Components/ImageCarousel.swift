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
    @State private var selectedImageIndex: Int = 0
    @State private var showFullscreenViewer: Bool = false
    
    var body: some View {
        TabView(selection: $selectedImageIndex) {
            ForEach(images.indices, id: \.self) { index in
                AsyncImageView(imageUrl: images[index])
                    .onTapGesture {
                        selectedImageIndex = index
                        showFullscreenViewer = true
                    }
                    .tag(index)
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .frame(height: 200)
        .cornerRadius(10)
        .fullScreenCover(isPresented: $showFullscreenViewer) {
            FullscreenImageViewer(
                images: images,
                currentIndex: $selectedImageIndex,
                isPresented: $showFullscreenViewer
            )
        }
    }
}
