import SwiftUI

struct HomeTabView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject var themeManager = ThemeManager()
    @StateObject var authManager = AuthManager.shared
    @State private var isCheckingAuth = true
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    // Top section with background image (fixed)
                    ZStack {
                        Image("home-profile-bg")
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .edgesIgnoringSafeArea(.all)

                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.01), Color.black.opacity(0.6)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )

                        // Top padding to position content below fixed header
                        VStack(alignment: .leading, spacing: 3) {
                            Text("TripTide")
                                .font(themeManager.selectedTheme.largerTitleFont)
                                .foregroundColor(themeManager.selectedTheme.accentColor)
                                .padding(.bottom, 5)
                                .shadow(color: themeManager.selectedTheme.accentColor.opacity(0.5), radius: 10, x: 0, y: 0)

                            Text("Discover the city with TripTide")
                                .font(themeManager.selectedTheme.largeTitleFont)
                                .foregroundColor(.white)

                            Text("Your personal guide to the best of Hong Kong")
                                .font(themeManager.selectedTheme.bodyTextFont)
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                        }
                        .padding(.top, 175)
                    }
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height * 0.6 // 45% of screen height
                    )
                    .blur(radius: min(scrollOffset / 5, 30))
                    .opacity(1.0 - (scrollOffset / 200))

                    // Content that scrolls
                    ScrollView {
                        GeometryReader { geometry in
                            Color.clear.preference(key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll")).minY)
                        }
                        .frame(height: 0)

                        ZStack(alignment: .top) {
                            Rectangle()
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .frame(minHeight: UIScreen.main.bounds.height)

                            VStack(alignment: .leading, spacing: 0) {
                                Text("Explore Hong Kong")
                                    .font(themeManager.selectedTheme.largeTitleFont)
                                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                            }
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 25)
                        }
                        .padding(.top, 375)
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = -value/5
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
