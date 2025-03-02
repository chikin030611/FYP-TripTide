import SwiftUI

struct WideCard: View {

    @StateObject var themeManager = ThemeManager()

    let place: Place

    init(place: Place) {
        self.place = place
    }

    var body: some View {
        NavigationLink(destination: PlaceDetailView(place: place)) {
            VStack {
                ZStack {
                    AsyncImageView(imageUrl: place.images[0], width: 300, height: 200)
                    // Image("home-profile-bg")
                    //     .resizable()
                    //     .frame(width: 300, height: 200)

                    HStack {
                        VStack(alignment: .leading) {
                            Text(place.name)
                                .font(themeManager.selectedTheme.boldBodyTextFont)
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(alignment: .bottomLeading)

                            ZStack {
                                Text(place.type.formatTagName())
                                    .font(themeManager.selectedTheme.captionTextFont)
                                    .foregroundColor(themeManager.selectedTheme.bgTextColor)
                            }
                            .padding(.horizontal, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(themeManager.selectedTheme.accentColor)
                            )
                        }

                        Spacer()

                        Image(systemName: "star.fill")
                            .foregroundColor(themeManager.selectedTheme.accentColor)
                            .frame(width: 20, height: 20)
                        Text("\(place.rating, specifier: "%.1f")")
                            .font(themeManager.selectedTheme.bodyTextFont)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 130)
                    .padding(.horizontal, 15)
                    .background(
                        Rectangle()
                            .fill(Color.black.opacity(0.7))
                            .frame(width: 300, height: 70)
                            .padding(.top, 130)
                    )
                }
                .frame(width: 300, height: 200)
                .cornerRadius(10)
            }
            .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 10)
        }
    }
}
