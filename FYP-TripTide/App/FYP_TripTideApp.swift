//
//  FYP_TripTideApp.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 26/9/2024.
//

import SwiftUI
import Inject

@main
struct FYP_TripTideApp: App {
    @ObserveInjection var inject
    @StateObject var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .enableInjection()
        }
    }
}
