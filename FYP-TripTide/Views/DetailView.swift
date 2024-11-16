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
    
    
    @State var images: [Image] = [Image("test_dark"), Image("test_light")]
    @State var tags: [Tag] = [Tag(name: "Amusement Park"), Tag(name: "Entertainment")]
    
    @State private var coordinate = CLLocationCoordinate2D(latitude: 33.8121, longitude: -117.9190)
    @State private var cameraPosition: MapCameraPosition
    
    init() {
        _cameraPosition = State(initialValue: .camera(
            .init(centerCoordinate: CLLocationCoordinate2D(latitude: 33.8121, longitude: -117.9190), distance: 2000)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                
                // Images
                ImageCarousel(images: images)
                    .padding(.top, 20)
                
                // Body
                VStack {
                    // Title
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Disneyland")
                                .font(themeManager.selectedTheme.largeTitleFont)
                            
                            HStack {
                                ForEach(tags, id: \.name) { tag in
                                    Text(tag.name)
                                        .font(themeManager.selectedTheme.captionTextFont)
                                    if (tag != tags.last) {
                                        Text("•")
                                            .font(themeManager.selectedTheme.captionTextFont)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "heart")
                            .font(.title)
                    }
                    .padding(.bottom, 10)
                    
                    // Open Hour
                    OpenHourRow()
                        .padding(.bottom, 10)
                    
                    // Recommended Staying Time
                    HStack {
                        Image(systemName: "clock")
                            .font(themeManager.selectedTheme.boldTitleFont)
                            .foregroundStyle(themeManager.selectedTheme.primaryColor)
                        
                        VStack(alignment: .leading) {
                            Text("Recommended Staying Time")
                                .font(themeManager.selectedTheme.boldBodyTextFont)
                                .foregroundStyle(themeManager.selectedTheme.primaryColor)
                            
                            Text("4 hours")
                                .font(themeManager.selectedTheme.bodyTextFont)
                                .foregroundStyle(themeManager.selectedTheme.primaryColor)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                    
                    // Description
                    Text("Disneyland Park, originally Disneyland, is the first of two theme parks built at the Disneyland Resort in Anaheim, California, opened on July 17, 1955. It is the only theme park designed and built to completion under the direct supervision of Walt Disney.")
                        .font(themeManager.selectedTheme.bodyTextFont)
                        .foregroundStyle(themeManager.selectedTheme.primaryColor)
                        .padding(.bottom, 10)
                    
                    // Location
                    Text("Location")
                        .font(themeManager.selectedTheme.boldTitleFont)
                        .foregroundStyle(themeManager.selectedTheme.primaryColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Map(position: $cameraPosition) {
                        Marker("DisneyLand", coordinate: coordinate)
                    }
                    .frame(height: 200)
                }
            }
        }
    }
}

#Preview {
    DetailView()
}
