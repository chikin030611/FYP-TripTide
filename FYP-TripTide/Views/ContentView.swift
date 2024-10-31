//
//  ContentView.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 26/9/2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var themeManager = ThemeManager()
    
    var body: some View {
        TabView {
            ExploreTabView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Explore")
                }
            ExploreTabView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favourites")
                }
        }
        .accentColor(themeManager.selectedTheme.accentColor)
        .environmentObject(themeManager)
    }
}

#Preview {
    ContentView()
}
