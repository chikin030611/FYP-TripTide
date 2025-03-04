//
//  StyleDisplayer.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 3/11/2024.
//

import UIKit
import SwiftUI
import Inject
import HorizonCalendar

struct UITestView: View {
    @ObserveInjection var injection
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedStartDate: Date?
    @State private var selectedEndDate: Date?
    @State private var trip: Trip

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

    init() {
        trip = Trip(
            id: "1",
            userId: "1",
            name: "Trip to Tokyo",
            description: "A trip to Tokyo",
            touristAttractionsIds: [place.id],
            restaurantsIds: [],
            lodgingsIds: [],
            startDate: Date(),
            endDate: Date()
        )
    }

    @State private var text: String = "Hello, world!"
    
    var body: some View {
        VStack(spacing: 20) {
            LargeCard(place: place)
            WideCard(place: place)

        }
        .enableInjection()

    }
}
