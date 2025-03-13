import SwiftUI

struct ItineraryView: View {
    let dailyItineraries: [DailyItinerary]?
    let numberOfDays: Int
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedDayIndex = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            if let itineraries = dailyItineraries, !itineraries.isEmpty {
                // Days picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(0..<numberOfDays, id: \.self) { index in
                            Button(action: {
                                selectedDayIndex = index
                            }) {
                                Text("Day \(index + 1)")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedDayIndex == index ? 
                                                  themeManager.selectedTheme.accentColor : 
                                                  themeManager.selectedTheme.backgroundColor)
                                    )
                                    .foregroundColor(selectedDayIndex == index ?
                                                    .white : 
                                                    themeManager.selectedTheme.primaryColor)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Selected day's scheduled places
                if selectedDayIndex < itineraries.count {
                    let day = itineraries[selectedDayIndex]
                    let places = day.places
                    
                    if !places.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(places) { place in
                                ScheduledPlaceView(scheduledPlace: place)
                            }
                        }
                    } else {
                        ContentUnavailableView(
                            "No Activities Planned",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("No activities have been scheduled for Day \(day.dayNumber).")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Itinerary Found",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("This trip doesn't have an itinerary yet.")
                )
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
            }
        }
        .padding()
        .background(themeManager.selectedTheme.appBackgroundColor)
        .cornerRadius(12)
    }
}

// Sub-view for each scheduled place
struct ScheduledPlaceView: View {
    let scheduledPlace: ScheduledPlace
    @StateObject private var themeManager = ThemeManager()
    @State private var placeName: String = "Loading..."
    @State private var placeImage: String = "placeholder"
    @State private var isLoading = true
    @State private var loadingError: String? = nil
    
    private let placesService = PlacesService.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Time column
            VStack(alignment: .trailing, spacing: 4) {
                if let startTime = scheduledPlace.startTime, 
                   let endTime = scheduledPlace.endTime {
                    Text(formatTime(startTime))
                        .font(themeManager.selectedTheme.bodyTextFont)
                        .foregroundColor(themeManager.selectedTheme.primaryColor)
                    
                    Text(formatTime(endTime))
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundColor(themeManager.selectedTheme.secondaryColor)
                } else {
                    Text("No time")
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundColor(themeManager.selectedTheme.secondaryColor)
                }
            }
            .frame(width: 80)
            
            // Vertical line
            Rectangle()
                .fill(themeManager.selectedTheme.accentColor)
                .frame(width: 2)
                .padding(.vertical, 4)
            
            // Place details
            VStack(alignment: .leading, spacing: 8) {
                if isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading place details...")
                            .font(themeManager.selectedTheme.captionTextFont)
                            .foregroundColor(themeManager.selectedTheme.secondaryColor)
                    }
                } else if let error = loadingError {
                    VStack(alignment: .leading) {
                        Text("Error loading place")
                            .font(themeManager.selectedTheme.bodyTextFont)
                            .foregroundColor(themeManager.selectedTheme.primaryColor)
                        Text(error)
                            .font(themeManager.selectedTheme.captionTextFont)
                            .foregroundColor(themeManager.selectedTheme.warningColor)
                    }
                } else {
                    Text(placeName)
                        .font(themeManager.selectedTheme.bodyTextFont)
                        .foregroundColor(themeManager.selectedTheme.primaryColor)
                    
                    if let notes = scheduledPlace.notes, !notes.isEmpty {
                        Text(notes)
                            .font(themeManager.selectedTheme.captionTextFont)
                            .foregroundColor(themeManager.selectedTheme.secondaryColor)
                            .lineLimit(2)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(themeManager.selectedTheme.backgroundColor)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .onAppear {
            loadPlaceDetails()
        }
    }
    
    private func loadPlaceDetails() {
        Task {
            isLoading = true
            loadingError = nil
            
            do {
                // Try to fetch place basic data
                let placeData = try await placesService.fetchPlaceBasicById(id: scheduledPlace.placeId)
                
                await MainActor.run {
                    placeName = placeData.name
                    placeImage = placeData.photoUrl
                    isLoading = false
                }
            } catch {
                // For demo/development, if it's a Google Place ID that's not in our database,
                // extract a readable name from it
                let placeName = formatGooglePlaceId(scheduledPlace.placeId)
                
                await MainActor.run {
                    self.placeName = placeName
                    isLoading = false
                    print("Error loading place details: \(error)")
                }
            }
        }
    }
    
    private func formatGooglePlaceId(_ placeId: String) -> String {
        // If this looks like a Google Place ID, try to make it readable
        if placeId.hasPrefix("ChIJ") {
            return "Place from Google Maps"
        } else {
            return "Place: \(placeId)"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}