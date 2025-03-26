import SwiftUI

struct ItineraryPreviewView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject var viewModel: EditItineraryViewModel
    let onConfirm: () -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) private var dismissPreview
    
    // Add this computed property to sort places by start time
    private var sortedPlaces: [ScheduledPlaceInput] {
        return viewModel.scheduledPlaces.sorted { place1, place2 in
            // Get the start times, defaulting to a far future date if nil
            let time1 = place1.startTime ?? Date.distantFuture
            let time2 = place2.startTime ?? Date.distantFuture
            
            // Sort by start time
            return time1 < time2
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                themeManager.selectedTheme.appBackgroundColor.ignoresSafeArea()
                
                // Content area - position to avoid overlap with buttons
                VStack(alignment: .leading, spacing: 16) {
                    // Current day title
                    HStack {
                        Text("Day \(viewModel.day)")
                            .font(themeManager.selectedTheme.titleFont)
                            .foregroundColor(themeManager.selectedTheme.primaryColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(themeManager.selectedTheme.primaryColor, lineWidth: 1)
                            )
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Scheduled places
                    if viewModel.scheduledPlaces.isEmpty {
                        ContentUnavailableView(
                            "No Places Scheduled",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("You haven't scheduled any places for this day yet.")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                // Use the sorted places instead of the original array
                                ForEach(sortedPlaces) { place in
                                    ScheduledPlacePreviewView(scheduledPlace: place, availablePlaces: viewModel.availablePlaces)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.top)
                .padding(.bottom, 80) // Add padding to avoid content being covered by button
                
                // Confirmation buttons - aligned to bottom
                HStack {
                    Button(viewModel.isEditing ? "Confirm Changes" : "Create Itinerary") {
                        onConfirm()
                        dismissPreview()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
                .background(Color.clear) // Optional for tap area
            }
            .navigationTitle(viewModel.isEditing ? "Preview Changes" : "Preview Itinerary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { 
                        onCancel()
                        dismissPreview()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
            .onAppear {
                print("🔍 ItineraryPreviewView appeared with \(viewModel.scheduledPlaces.count) places")
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                
                for (index, place) in viewModel.scheduledPlaces.enumerated() {
                    let placeName = viewModel.availablePlaces.first(where: { $0.id == place.placeId })?.name ?? "Unknown"
                    let startTimeStr = place.startTime.map { formatter.string(from: $0) } ?? "nil"
                    let endTimeStr = place.endTime.map { formatter.string(from: $0) } ?? "nil"
                    
                    print("🔍 Preview Place \(index): \(placeName), Start=\(startTimeStr), End=\(endTimeStr)")
                }
            }
        }
    }
}

struct ScheduledPlacePreviewView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let scheduledPlace: ScheduledPlaceInput
    let availablePlaces: [Place]
    
    private var selectedPlace: Place? {
        guard let placeId = scheduledPlace.placeId else { return nil }
        return availablePlaces.first { $0.id == placeId }
    }
    
    var body: some View {
        if let place = selectedPlace {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 12) {
                    // Time
                    VStack(spacing: 4) {
                        if let startTime = scheduledPlace.startTime, let endTime = scheduledPlace.endTime {
                            Text(formatTime(startTime))
                                .font(themeManager.selectedTheme.bodyTextFont)
                                .foregroundColor(themeManager.selectedTheme.primaryColor)
                                .onAppear {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "HH:mm:ss"
                                    print("🕒 Rendering time for \(place.name): \(formatter.string(from: startTime)) to \(formatter.string(from: endTime))")
                                }
                            
                            Text("to")
                                .font(themeManager.selectedTheme.captionTextFont)
                                .foregroundColor(themeManager.selectedTheme.secondaryColor)
                            
                            Text(formatTime(endTime))
                                .font(themeManager.selectedTheme.bodyTextFont)
                                .foregroundColor(themeManager.selectedTheme.primaryColor)
                        }
                    }
                    .frame(width: 65)
                    .padding(.vertical, 8)
                    
                    // Vertical line
                    Rectangle()
                        .fill(themeManager.selectedTheme.accentColor)
                        .frame(width: 2)
                        .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Type
                        ZStack {
                            Text(place.type.formatTagName())
                                .font(themeManager.selectedTheme.captionTextFont)
                                .foregroundColor(themeManager.selectedTheme.bgTextColor)
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(themeManager.selectedTheme.accentColor)
                        )
                        
                        // Name
                        Text(place.name)
                            .font(themeManager.selectedTheme.boldBodyTextFont)
                            .foregroundColor(themeManager.selectedTheme.primaryColor)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        // Notes if available
                        if let notes = scheduledPlace.notes, !notes.isEmpty {
                            Text(notes)
                                .font(themeManager.selectedTheme.captionTextFont)
                                .foregroundColor(themeManager.selectedTheme.secondaryColor)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                
                Divider()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
