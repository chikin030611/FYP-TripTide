//
//  Place.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 4/11/2024.
//

import SwiftUI
import CoreLocation
import MapKit

struct PlaceDetailView: View {
    @StateObject var themeManager = ThemeManager()
    @StateObject private var viewModel: PlaceDetailViewModel
    @State private var showMap = false
    @State private var showAddressOptions = false
    @State private var showToast = false
    @State private var showAddToTripSheet = false
    @State private var isAnimating: Bool = false
    
    init(place: Place) {
        _viewModel = StateObject(wrappedValue: PlaceDetailViewModel(placeId: place.id))
    }
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.error {
            Text("Error loading place: \(error.localizedDescription)")
                .foregroundColor(.red)
        } else {
            ScrollView {
                VStack {
                    // Images
                    ImageCarousel(images: viewModel.place.images)
                    
                    // Body
                    VStack {
                        // Header
                        headerSection
                        
                        // Open Hour
                        OpenHourRow(openHours: viewModel.place.openHours)
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
                AddressActionSheet(address: viewModel.place.address) {
                    showToast = true
                }
            }
            .overlay(alignment: .bottom) {
                if showToast {
                    Toast(message: "Address copied!", isPresented: $showToast)
                }
            }
            .animation(.easeInOut, value: showToast)
            // Listen for notifications about place being added/removed from trips
            .onReceive(NotificationCenter.default.publisher(for: .placeAddedToTrip)) { _ in
                Task {
                    await viewModel.checkIfPlaceInAnyTrip(placeId: viewModel.place.id)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .placeRemovedFromTrip)) { _ in
                Task {
                    await viewModel.checkIfPlaceInAnyTrip(placeId: viewModel.place.id)
                }
            }
        }
    }

    // MARK: - View Components
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.place.name)
                    .font(themeManager.selectedTheme.largeTitleFont)
                
                Rating(rating: viewModel.place.rating, ratingCount: viewModel.place.ratingCount)
                
                if !viewModel.place.price.isEmpty || viewModel.place.price != "" {
                    PriceAndTags(price: viewModel.place.price, tags: viewModel.place.tags)
                } else {
                    TagGroup(tags: viewModel.place.tags)
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isAnimating = false
                    }
                }
                print("🔘 AddToTripSheet button tapped at \(Date())")
                showAddToTripSheet = true
            }) {
                Text(viewModel.isInTrip ? "Remove" : "Add")
            }
            .buttonStyle(HeartToggleInDetailViewButtonStyle(isAdded: viewModel.isInTrip))
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .id("heart-button-\(viewModel.isInTrip)")
        }
        .padding(.bottom, 10)
        .onChange(of: showAddToTripSheet) { oldValue, newValue in
            if newValue {
                print("🔍 AddToTripSheet will present at \(Date())")
            } else {
                print("🔍 AddToTripSheet dismissed at \(Date())")
            }
        }
        .sheet(isPresented: $showAddToTripSheet) {
            AddToTripSheet(
                place: viewModel.place,
                onAddPlaceToTrip: { place, trip in
                    // Then verify with backend
                    Task {
                        await viewModel.checkIfPlaceInAnyTrip(placeId: viewModel.place.id)
                    }
                },
                onRemovePlaceFromTrip: { place, trip in
                    // Check if the place is still in any trip after removal
                    Task {
                        await viewModel.checkIfPlaceInAnyTrip(placeId: viewModel.place.id)
                    }
                }
            )
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
                
                Text(viewModel.place.stayingTime)
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 10)
    }
    
    private var descriptionSection: some View {
        Text(viewModel.place.description)
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
                Text(viewModel.place.address)
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
                    .underline()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .sheet(isPresented: $showAddressOptions) {
                AddressActionSheet(address: viewModel.place.address, onCopy: {
                    showToast = true
                })
            }

            Button {
                showMap.toggle()
            } label: {
                Map(position: $viewModel.cameraPosition, interactionModes: []) {
                    Marker(viewModel.place.name, coordinate: CLLocationCoordinate2D(
                        latitude: viewModel.place.latitude,
                        longitude: viewModel.place.longitude))
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.selectedTheme.primaryColor.opacity(0.2), lineWidth: 1)
                )
            }
            .sheet(isPresented: $showMap) {
                PlaceMapView(place: viewModel.place)
            }
        }
    }
}
