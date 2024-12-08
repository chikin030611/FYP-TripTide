//
//  Attraction.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 4/11/2024.
//

import SwiftUI
import CoreLocation
import MapKit

// TODO: Lock the map control
// TODO: Add favorite functionality
// TODO: Add the navigation to the opening hours

struct AttractionDetailView: View {
    @StateObject var themeManager = ThemeManager()
    @StateObject private var viewModel: AttractionDetailViewModel
    
    init(attraction: Attraction) {
        _viewModel = StateObject(wrappedValue: AttractionDetailViewModel(attractionId: attraction.id))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // Images
                ImageCarousel(images: viewModel.attraction.images)
                    .padding(.top, 20)
                
                // Body
                VStack {
                    // Header
                    headerSection
                    
                    // Open Hour
                    OpenHourRow(openHours: viewModel.attraction.openHours)
                        .padding(.bottom, 10)
                    
                    // Recommended Staying Time
                    stayingTimeSection
                    
                    // Description
                    descriptionSection
                    
                    // Location
                    locationSection
                }
            }
        }
        .padding(10)
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.attraction.name)
                    .font(themeManager.selectedTheme.largeTitleFont)
                
                ratingStars
                
                priceAndTags
            }
            
            Spacer()
            
            Image(systemName: "heart")
                .font(.title)
                .onTapGesture {
                    viewModel.toggleFavorite()
                }
        }
        .padding(.bottom, 10)
    }
    
    private var ratingStars: some View {
        HStack {
            ForEach(0..<viewModel.rating, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundStyle(themeManager.selectedTheme.accentColor)
            }
            
            ForEach(0..<viewModel.remainingStars, id: \.self) { _ in
                Image(systemName: "star")
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundStyle(themeManager.selectedTheme.accentColor)
            }
        }
    }
    
    private var priceAndTags: some View {
        HStack {
            Text(viewModel.attraction.price)
                .font(themeManager.selectedTheme.captionTextFont)
            Text("•")
                .font(themeManager.selectedTheme.captionTextFont)
            ForEach(viewModel.attraction.tags, id: \.name) { tag in
                Text(tag.name)
                    .font(themeManager.selectedTheme.captionTextFont)
                if tag != viewModel.attraction.tags.last {
                    Text("•")
                        .font(themeManager.selectedTheme.captionTextFont)
                }
            }
        }
    }
    
    private var stayingTimeSection: some View {
        HStack {
            Image(systemName: "clock")
                .frame(width: 25, height: 25)
                .font(themeManager.selectedTheme.boldTitleFont)
                .foregroundStyle(themeManager.selectedTheme.primaryColor)
            
            VStack(alignment: .leading) {
                Text("Recommended Staying Time")
                    .font(themeManager.selectedTheme.boldBodyTextFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
                
                Text(viewModel.attraction.stayingTime)
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 10)
    }
    
    private var descriptionSection: some View {
        Text(viewModel.attraction.description)
            .font(themeManager.selectedTheme.bodyTextFont)
            .foregroundStyle(themeManager.selectedTheme.primaryColor)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading) {
            Text("Location")
                .font(themeManager.selectedTheme.boldTitleFont)
                .foregroundStyle(themeManager.selectedTheme.primaryColor)
            
            Map(position: $viewModel.cameraPosition) {
                Marker(viewModel.attraction.name, coordinate: CLLocationCoordinate2D(
                    latitude: viewModel.attraction.latitude,
                    longitude: viewModel.attraction.longitude))
            }
            .frame(height: 200)
        }
    }
}
