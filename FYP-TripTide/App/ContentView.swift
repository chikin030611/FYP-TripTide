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
    
    // private var items: [BottomBarItem] {
    //     [
    //         BottomBarItem(icon: "house.fill", title: "Explore", color: themeManager.selectedTheme.accentColor),
    //         BottomBarItem(icon: "magnifyingglass", title: "Search", color: themeManager.selectedTheme.accentColor),
    //         BottomBarItem(icon: "lightbulb.fill", title: "Tips", color: themeManager.selectedTheme.accentColor),
    //         BottomBarItem(icon: "person.fill", title: "Profile", color: themeManager.selectedTheme.accentColor)
    //     ]
    // }

    private var items: [BottomBarItem] {
        [
            BottomBarItem(icon: "paintbrush.fill", title: "UI Test", color: themeManager.selectedTheme.accentColor),
            BottomBarItem(icon: "house.fill", title: "Explore", color: themeManager.selectedTheme.accentColor),
            BottomBarItem(icon: "magnifyingglass", title: "Search", color: themeManager.selectedTheme.accentColor),
            BottomBarItem(icon: "lightbulb.fill", title: "Tips", color: themeManager.selectedTheme.accentColor)
        ]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Main content area
                // Group {
                //     switch selectedIndex {
                //     case 0:
                //         ExploreTabView()
                //     case 1:
                //         SearchTabView()
                //     case 2:
                //         TipsTabView()
                //     case 3:
                //         UserTabView()
                //     default:
                //         ExploreTabView()
                //     }
                // }

                Group {
                    switch selectedIndex {
                    case 0:
                        UITestView()
                    case 1:
                        ExploreTabView()
                    case 2:
                        SearchTabView()
                    case 3:
                        TipsTabView()
                    default:
                        UITestView()
                    }
                }
                
                Spacer()
                
                // Bottom Bar
                BottomBar(selectedIndex: $selectedIndex, items: items)
                    .padding(.bottom, 35)
                    .frame(height: 100)

            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .accentColor(themeManager.selectedTheme.accentColor)
        .environmentObject(themeManager)
        .enableInjection()
    }
}

#Preview {
    ContentView()
}
