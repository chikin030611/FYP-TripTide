//
//  DetailView.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 4/11/2024.
//

import SwiftUI
import CoreLocation
import MapKit

struct DetailView: View {
    
    @StateObject var themeManager = ThemeManager()
    
    // Property to hold a Place object
    // var place: Place
    var placeId: String
    @State private var place: Place = .empty

    @State private var cameraPosition: MapCameraPosition
    
    init(place: Place) {
        self.placeId = place.id
        self.place = getPlace(by: placeId) ?? .empty
        _cameraPosition = State(initialValue: .camera(
            .init(centerCoordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude), distance: 2000)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                
                // Images
                ImageCarousel(images: place.images)
                    .padding(.top, 20)
                
                // Body
                VStack {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            
                            // Title
                            Text(place.name)
                                .font(themeManager.selectedTheme.largeTitleFont)
                            
                            // Rating
                            HStack {
                                ForEach(Array(repeating: true, count: place.rating), id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .font(themeManager.selectedTheme.captionTextFont)
                                        .foregroundStyle(themeManager.selectedTheme.accentColor)
                                }

                                ForEach(Array(repeating: true, count: 5-place.rating), id: \.self) { _ in
                                    Image(systemName: "star")
                                        .font(themeManager.selectedTheme.captionTextFont)
                                        .foregroundStyle(themeManager.selectedTheme.accentColor)
                                }

                            }
                        
                            // Price and Tags
                            HStack {
                                Text(place.price)
                                    .font(themeManager.selectedTheme.captionTextFont)
                                Text("•")
                                    .font(themeManager.selectedTheme.captionTextFont)
                                ForEach(place.tags, id: \.name) { tag in
                                    Text(tag.name)
                                        .font(themeManager.selectedTheme.captionTextFont)
                                    if tag != place.tags.last {
                                        Text("•")
                                            .font(themeManager.selectedTheme.captionTextFont)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // TODO: Add a button to favourite the place
                        // TODO: Make the button pressable
                        Image(systemName: "heart")
                            .font(.title)
                    }
                    .padding(.bottom, 10)
                    
                    // Open Hour
                    OpenHourRow(openHours: place.openHours)
                        .padding(.bottom, 10)
                    
                    // Recommended Staying Time
                    HStack {
                        Image(systemName: "clock")
                            .frame(width: 25, height: 25)
                            .font(themeManager.selectedTheme.boldTitleFont)
                            .foregroundStyle(themeManager.selectedTheme.primaryColor)
                        
                        VStack(alignment: .leading) {
                            Text("Recommended Staying Time")
                                .font(themeManager.selectedTheme.boldBodyTextFont)
                                .foregroundStyle(themeManager.selectedTheme.primaryColor)
                            
                            Text(place.stayingTime)
                                .font(themeManager.selectedTheme.bodyTextFont)
                                .foregroundStyle(themeManager.selectedTheme.primaryColor)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                    
                    // Description
                    Text(place.description)
                        .font(themeManager.selectedTheme.bodyTextFont)
                        .foregroundStyle(themeManager.selectedTheme.primaryColor)
                        .padding(.bottom, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Location
                    Text("Location")
                        .font(themeManager.selectedTheme.boldTitleFont)
                        .foregroundStyle(themeManager.selectedTheme.primaryColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Map(position: $cameraPosition) {
                        Marker(place.name, coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))
                    }
                    .frame(height: 200)
                }
            }
        }
    }
}

// #Preview {
//     DetailView(place: Place(
//         images: ["https://dummyimage.com/600x400/ffc14f/ffffff", "https://dummyimage.com/600x400/07162e/ffffff"],
//         name: "Disneyland",
//         rating: 4,
//         price: "$500+",
//         tags: [Tag(name: "Amusement Park"), Tag(name: "Entertainment")],
//         openHours: [
//             OpenHour(weekdayIndex: 1, openTime: "00:00", closeTime: "03:50"),
//             OpenHour(weekdayIndex: 2, openTime: "10:00", closeTime: "18:00"),
//             OpenHour(weekdayIndex: 3, openTime: "10:00", closeTime: "19:00"),
//             OpenHour(weekdayIndex: 4, openTime: "10:00", closeTime: "20:00"),
//             OpenHour(weekdayIndex: 5, openTime: "10:00", closeTime: "20:00"),
//             OpenHour(weekdayIndex: 6, openTime: "10:00", closeTime: "20:00"),
//             OpenHour(weekdayIndex: 7, openTime: nil, closeTime: nil)
//         ],
//         stayingTime: "4 hours",
//         description: "Disneyland Park is the first theme park built at Disneyland Resort in Anaheim, California.",
//         latitude: 33.8121,
//         longitude: -117.9190
//     ))
// }
