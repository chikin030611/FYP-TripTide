//
//  ContentView.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 26/9/2024.
//

import SwiftUI
import BottomBar_SwiftUI
import Inject

struct ContentView: View {
    @ObserveInjection var injection
    @State private var selectedIndex: Int = 0
    @StateObject var themeManager = ThemeManager()
    
    // Add StateObjects for tab view models to preserve their state
    @StateObject private var searchTabViewModel = SearchTabViewModel()

    private var items: [BottomBarItem] {
        [
            BottomBarItem(icon: "paintbrush.fill", title: "UI Test", color: themeManager.selectedTheme.accentColor),
            BottomBarItem(icon: "house.fill", title: "Home", color: themeManager.selectedTheme.accentColor),
            BottomBarItem(icon: "magnifyingglass", title: "Search", color: themeManager.selectedTheme.accentColor),
            BottomBarItem(icon: "lightbulb.fill", title: "Tips", color: themeManager.selectedTheme.accentColor),
            BottomBarItem(icon: "person.fill", title: "Profile", color: themeManager.selectedTheme.accentColor)
        ]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.selectedTheme.appBackgroundColor.edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    Group {
                        switch selectedIndex {
                        case 0:
                            UITestView()
                        case 1:
                            HomeTabView()
                        case 2:
                            SearchTabView(viewModel: searchTabViewModel)
                        case 3:
                            TipsTabView()
                        case 4:
                            UserTabView()
                        default:
                            UITestView()
                        }
                    }
                
                    Spacer()
                    
                    // Bottom Bar
                    BottomBar(selectedIndex: $selectedIndex, items: items)
                        .padding(.bottom, 35)
                        .frame(height: 90)

                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .accentColor(themeManager.selectedTheme.accentColor)
        .environmentObject(themeManager)
        .enableInjection()
    }
}

#Preview {
    ContentView()
}
