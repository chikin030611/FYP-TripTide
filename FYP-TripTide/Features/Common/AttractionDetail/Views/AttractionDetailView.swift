//
//  Attraction.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 4/11/2024.
//

import SwiftUI
import CoreLocation
import MapKit
import Inject

// TODO: Add favorite functionality

struct AttractionDetailView: View {
    @StateObject var themeManager = ThemeManager()
    @StateObject private var viewModel: AttractionDetailViewModel
    @State private var showMap = false
    @State private var showAddressOptions = false
    @State private var showToast = false
    
    init(attraction: Attraction) {
        _viewModel = StateObject(wrappedValue: AttractionDetailViewModel(attractionId: attraction.id))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // Images
                // TODO: Press to zoom in
                ImageCarousel(images: viewModel.attraction.images)
                
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
            .padding()
        }
        .sheet(isPresented: $showAddressOptions) {
            AddressActionSheet(address: viewModel.attraction.address) {
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showToast = false
                }
            }
        }
        .overlay(alignment: .bottom) {
            if showToast {
                Text("Address copied!")
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(themeManager.selectedTheme.primaryColor.opacity(0.8))
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 10)
            }
        }
        .animation(.easeInOut, value: showToast)
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.attraction.name)
                    .font(themeManager.selectedTheme.largeTitleFont)
                
                Rating(rating: viewModel.attraction.rating)
                
                PriceAndTags(price: viewModel.attraction.price, tags: viewModel.attraction.tags)
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

            Button {
                showAddressOptions.toggle()
            } label: {
                Text(viewModel.attraction.address)
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
                    .underline()
            }
            .sheet(isPresented: $showAddressOptions) {
                AddressActionSheet(address: viewModel.attraction.address, onCopy: {
                    showToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showToast = false
                    }
                })
            }

            Button {
                showMap.toggle()
            } label: {
                Map(position: $viewModel.cameraPosition, interactionModes: []) {
                    Marker(viewModel.attraction.name, coordinate: CLLocationCoordinate2D(
                        latitude: viewModel.attraction.latitude,
                        longitude: viewModel.attraction.longitude))
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.selectedTheme.primaryColor.opacity(0.2), lineWidth: 1)
                )
            }
            .sheet(isPresented: $showMap) {
                AttractionMapView(attraction: viewModel.attraction)
            }
        }
    }
}
