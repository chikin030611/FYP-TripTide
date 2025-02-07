//
//  StyleDisplayer.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 3/11/2024.
//

import SwiftUI

struct UITestView: View {
    @StateObject private var filterViewModel = FilterViewModel()
    @StateObject private var themeManager = ThemeManager()
    @State private var isFilterSheetPresented = false
    let filterOptions = ["Amusement Park", "Beach"]
    @State private var filterOptionsCount = 5
    let place = Place(
        id: "1",
        images: ["https://picsum.photos/200/300"],
        name: "Amusement Park",
        rating: 4.5,
        price: "$",
        tags: [Tag(name: "Amusement Park"), Tag(name: "Beach")],
        openHours: [OpenHour(from: ["open": ["day": 1, "hour": 9, "minute": 0], "close": ["day": 1, "hour": 17, "minute": 0]])],
        stayingTime: "2 hours",
        description: "A fun amusement park with rides and games",
        address: "123 Main St, Anytown, USA",
        latitude: 37.7749,
        longitude: 122.4194
    )
    
    var body: some View {
        SearchResultRow(place: place)
    }
}

#Preview {
    UITestView()
}
