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
        VStack {
            TabView {
                ForEach(images.indices, id: \.self) { index in
                    AsyncImage(url: stringToURL(images[index])) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()  // Placeholder when loading
                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: .infinity)
                                .clipped()
                        case .failure:
                            Image(systemName: "exclamationmark.triangle.fill") // Error handling
                                .foregroundColor(.red)
                                .frame(width: .infinity)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .frame(height: 200)
            .cornerRadius(10)
        }
    }
}
