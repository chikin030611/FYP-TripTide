//
//  StyleDisplayer.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 3/11/2024.
//

import SwiftUI
import Inject

struct UITestView: View {
    @ObserveInjection var injection
    @StateObject private var themeManager = ThemeManager()

    let place = Place(
        id: "1",
        images: ["https://picsum.photos/300/300"],
        name: "Amusement Park",
        type: "Tourist Attraction",
        rating: 4.5,
        ratingCount: 100,
        price: "$",
        tags: [Tag(name: "Amusement Park"), Tag(name: "Beach"), Tag(name: "Family Friendly")],
        openHours: [OpenHour(from: ["open": ["day": 1, "hour": 9, "minute": 0], "close": ["day": 1, "hour": 17, "minute": 0]])],
        stayingTime: "2 hours",
        description: "A fun amusement park with rides and games",
        address: "123 Main St, Anytown, USA",
        latitude: 37.7749,
        longitude: 122.4194
    )
    
    var body: some View {
        NavigationView {
            WideCard(place: place)
            LargeCard(place: place)

        }
        .enableInjection()
    }
}


#Preview {
    UITestView()
}
