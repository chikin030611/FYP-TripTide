import SwiftUI

struct HomeTabView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject var themeManager = ThemeManager()
    @StateObject var authManager = AuthManager.shared
    @EnvironmentObject var tabManager: TabManager

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

                        // Top content now uses relative positioning
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
                                
                                Text("Search places...")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
                            }
                            .padding()
                            .frame(width: geometry.size.width * 0.95, height: 40, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(themeManager.selectedTheme.backgroundColor)
                            )
                            .onTapGesture {
                                tabManager.switchToTab(1)
                            }

                            Spacer()

                            VStack(alignment: .leading, spacing: 3) {
                                Text("TripTide")
                                    .font(themeManager.selectedTheme.largerTitleFont)
                                    .foregroundColor(themeManager.selectedTheme.accentColor)
                                    .padding(.bottom, 5)
                                    .shadow(color: themeManager.selectedTheme.accentColor.opacity(0.5), radius: 15, x: 0, y: 0)

                                Text("Discover Your Next Journey")
                                    .font(themeManager.selectedTheme.largeTitleFont)
                                    .foregroundColor(.white)

                                Text("Your personal guide to the best of Hong Kong")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 10)

                                Button(action: {
                                    tabManager.switchToTab(2)
                                }) {
                                    Text("Start Planning")
                                        .font(themeManager.selectedTheme.bodyTextFont)
                                        .foregroundColor(.white)
                                }
                                .buttonStyle(SmallerPrimaryButtonStyle())
                                .shadow(color: themeManager.selectedTheme.accentColor.opacity(0.62), radius: 15, x: 0, y: 0)

                            }
                            .padding(.bottom, geometry.size.height * 0.15)

                        }
                        .padding(.top, geometry.size.height * 0.1)
                        .padding(.horizontal, 15)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height * 0.7
                    )
                    .blur(radius: -scrollOffset / 10 )
                    
                    // Content that scrolls
                    Rectangle()
                        .foregroundColor(themeManager.selectedTheme.appBackgroundColor)
                        .cornerRadius(20)
                        .overlay(
                            GeometryReader { cardGeometry in
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        Text("Recommended for you")
                                            .font(themeManager.selectedTheme.titleFont)
                                            .foregroundColor(themeManager.selectedTheme.primaryColor)
                                        Spacer()
                                        // Text("View All")
                                        //     .font(themeManager.selectedTheme.bodyTextFont)
                                        //     .foregroundColor(themeManager.selectedTheme.secondaryColor)
                                        //     .underline()
                                    }
                                    .padding(.bottom)
                                    .padding(.top, 20)

                                    if viewModel.isUserLoggedIn {
                                        CardGroup(cards: viewModel.cards, style: .wide)
                                            .padding(.horizontal, -10)
                                    } else {
                                        Text("Please log in to view your recommended places")
                                            .font(themeManager.selectedTheme.bodyTextFont)
                                            .foregroundColor(themeManager.selectedTheme.secondaryColor)
                                    }

                                    // HStack {
                                    //     Text("Popular Destinations")
                                    //         .font(themeManager.selectedTheme.titleFont)
                                    //         .foregroundColor(themeManager.selectedTheme.primaryColor)
                                    //     Spacer()
                                    //     Text("View All")
                                    //         .font(themeManager.selectedTheme.bodyTextFont)
                                    //         .foregroundColor(themeManager.selectedTheme.secondaryColor)
                                    //         .underline()
                                    // }
                                    // .padding(.bottom)

                                    // CardGroup(cards: viewModel.cards, style: .wide)
                                    //     .padding(.horizontal, -10)

                                    // Text("Explore Hong Kong")
                                    //     .font(themeManager.selectedTheme.titleFont)
                                    //     .foregroundColor(themeManager.selectedTheme.primaryColor)
                                    //     .padding(.bottom)

                                    // CardGroup(cards: viewModel.cards, style: .wide)
                                    //     .padding(.horizontal, -10)
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .top)
                                .padding(.top, cardGeometry.size.height * 0.01)
                            }
                        )
                        .offset(y: geometry.size.height * 0.6 + scrollOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    withAnimation(.interactiveSpring(
                                        response: 0.3,
                                        dampingFraction: 0.8,
                                        blendDuration: 0.5
                                    )) {
                                        let translation = value.translation.height * 0.2
                                        
                                        let resistance: CGFloat = 0.4
                                        if translation < 0 && scrollOffset <= -600 {
                                            let excess = translation * resistance
                                            scrollOffset = -600 + excess
                                        } else if translation > 0 && scrollOffset >= 0 {
                                            let excess = translation * resistance
                                            scrollOffset = excess
                                        } else {
                                            scrollOffset = min(0, max(-600, scrollOffset + translation))
                                        }
                                    }
                                }
                                .onEnded { value in
                                    withAnimation(.spring(
                                        response: 0.35,
                                        dampingFraction: 0.8,
                                        blendDuration: 0
                                    )) {
                                        let rawVelocity = value.predictedEndLocation.y - value.location.y
                                        let maxVelocity: CGFloat = 500
                                        let cappedVelocity = max(-maxVelocity, min(maxVelocity, rawVelocity))
                                        let scaledVelocity = cappedVelocity * 0.1
                                        
                                        let finalOffset = scrollOffset + scaledVelocity
                                        scrollOffset = min(0, max(-600, finalOffset))
                                    }
                                }
                        )

                }
                // .background(Color.black)
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