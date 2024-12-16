//
//  ContentView.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 26/9/2024.
//

import SwiftUI
import Inject

struct ContentView: View {
    @ObserveInjection var inject
    @StateObject var themeManager = ThemeManager()
    
    var body: some View {
        TabView {
            // UITestView()
            //     .tabItem {
            //         Image(systemName: "paintbrush")
            //         Text("Styles")
            //     }
            
            
            ExploreTabView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Explore")
                }

            SearchTabView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }

            PlanTabView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Plan")
                }

            TipsTabView()
                .tabItem {
                    Image(systemName: "lightbulb")
                    Text("Tips")
                }

            UserTabView()
                .tabItem {
                    Image(systemName: "person")
                    Text("User")
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
