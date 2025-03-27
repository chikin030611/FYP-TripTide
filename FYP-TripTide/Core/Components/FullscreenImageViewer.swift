import SwiftUI

struct FullscreenImageViewer: View {
    let images: [String]
    @Binding var currentIndex: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Image
            AsyncImageView(imageUrl: images[currentIndex])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(contentMode: .fit)
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
            
            // Navigation arrows
            HStack {
                // Left arrow (previous)
                Button {
                    withAnimation {
                        currentIndex = (currentIndex > 0) ? currentIndex - 1 : images.count - 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(.leading)
                .opacity(images.count > 1 ? 1 : 0)
                
                Spacer()
                
                // Right arrow (next)
                Button {
                    withAnimation {
                        currentIndex = (currentIndex < images.count - 1) ? currentIndex + 1 : 0
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(.trailing)
                .opacity(images.count > 1 ? 1 : 0)
            }
            
            // Page indicator
            VStack {
                Spacer()
                Text("\(currentIndex + 1) / \(images.count)")
                    .foregroundColor(.white)
                    .padding(.bottom)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.width > 50 {
                        // Swiped right - go to previous
                        withAnimation {
                            currentIndex = (currentIndex > 0) ? currentIndex - 1 : images.count - 1
                        }
                    } else if value.translation.width < -50 {
                        // Swiped left - go to next
                        withAnimation {
                            currentIndex = (currentIndex < images.count - 1) ? currentIndex + 1 : 0
                        }
                    }
                }
        )
    }
} 