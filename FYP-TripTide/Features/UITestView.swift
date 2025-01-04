//
//  StyleDisplayer.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 3/11/2024.
//

import SwiftUI

struct UITestView: View {
    @State private var openHours: [OpenHour] = []
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Test OpenHourRow
                VStack(alignment: .leading) {
                    Text("OpenHourRow Test")
                        .font(themeManager.selectedTheme.largeTitleFont)
                    
                    OpenHourRow(openHours: openHours)
                        .padding()
                        .background(themeManager.selectedTheme.backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
                
            }
            .navigationTitle("Opening Hours Test")
            .onAppear {
                loadTestData()
            }
        }
    }
    
    private func loadTestData() {
        // Load and parse test JSON file
        guard let url = Bundle.main.url(forResource: "test_hong_kong_places", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
              let place = json.first,
              let openingHours = place["openingHours"] as? [String: Any] else {
            print("Failed to load test data")
            return
        }
        
        // Parse opening hours
        openHours = OpenHour.createFromGooglePlaces(openingHours: openingHours)
    }
}

#Preview {
    UITestView()
}
