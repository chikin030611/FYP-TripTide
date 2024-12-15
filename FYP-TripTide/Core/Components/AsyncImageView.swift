import SwiftUI

struct AsyncImageView: View {
    let imageUrl: String
    var width: CGFloat?
    var height: CGFloat?
    let cornerRadius: CGFloat = 10

    var body: some View {
        AsyncImage(url: stringToURL(imageUrl)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: width,
                        height: height
                    )
                    .clipped()
                    .cornerRadius(cornerRadius)
            case .failure:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
            @unknown default:
                EmptyView()
            }
        }
    }
}