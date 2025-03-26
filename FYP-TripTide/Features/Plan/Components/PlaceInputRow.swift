import SwiftUI

// Add this helper view to handle sheet presentation separately from main view
struct OpeningHoursSheetWrapper: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let placeId: String
    @Binding var isPresented: Bool

    @State private var openingHours: [OpenHour] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading opening hours...")
            } else {
                OpenHoursSheet(openHours: openingHours)
                    .environmentObject(themeManager)
            }
        }
        .onAppear {
            print("📊 OpeningHoursSheetWrapper onAppear for placeId: \(placeId)")
            Task {
                do {
                    print("📊 Fetching hours from API for placeId: \(placeId)")
                    let hours = try await PlacesService.shared.fetchPlaceOpeningHours(id: placeId)
                    let openHours = [OpenHour].from(hours)

                    await MainActor.run {
                        print("📊 Hours loaded successfully: \(openHours.count) entries")
                        self.openingHours = openHours
                        self.isLoading = false
                    }
                } catch {
                    print("📊 Error loading opening hours: \(error)")
                    await MainActor.run {
                        self.isLoading = false
                    }
                }
            }
        }
    }
}

struct PlaceInputRow: View {
    @ObservedObject var placeInput: ScheduledPlaceInput
    let availablePlaces: [Place]
    let isLoading: Bool
    let onRemove: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject var viewModel: EditItineraryViewModel

    // Simplify state - just track if sheet is shown
    @State private var showOpeningHours = false

    // Compute selected place from placeInput.placeId
    private var selectedPlace: Place? {
        guard let placeId = placeInput.placeId else { return nil }
        return availablePlaces.first { $0.id == placeId }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // If we have a selected place, show the detailed view
            if let place = selectedPlace {
                HStack(alignment: .center, spacing: 12) {
                    // Image
                    if !place.images.isEmpty {
                        AsyncImageView(imageUrl: place.images[0], width: 130, height: 170)
                            .frame(width: 130, height: 170)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 130, height: 170)
                            .cornerRadius(8)
                    }

                    // Vertical line
                    Rectangle()
                        .fill(themeManager.selectedTheme.accentColor)
                        .frame(width: 2)
                        .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 2) {

                        // Name and Opening Hours Info Button
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
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

                                Text(place.name)
                                    .font(themeManager.selectedTheme.boldBodyTextFont)
                                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }

                            Spacer()

                            // Simplified button action
                            Button(action: {
                                print("ℹ️ Info button tapped for place: \(place.id)")
                                showOpeningHours = true
                            }) {
                                Image(systemName: "clock")
                                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
                                    .font(themeManager.selectedTheme.titleFont)
                            }
                            
                        }

                        // Times
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Start Time")
                                    .font(themeManager.selectedTheme.captionTextFont)
                                    .foregroundColor(themeManager.selectedTheme.secondaryColor)

                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: {
                                            if let time = placeInput.startTime {
                                                return time
                                            } else {
                                                // Default to 9:00 AM when first creating
                                                let calendar = Calendar.current
                                                var components = calendar.dateComponents(
                                                    [.year, .month, .day], from: Date())
                                                components.hour = 9
                                                components.minute = 0
                                                return calendar.date(from: components) ?? Date()
                                            }
                                        },
                                        set: { newTime in
                                            let formatter = DateFormatter()
                                            formatter.dateFormat = "HH:mm:ss"
                                            print(
                                                "⏰ Start time picker changed to \(formatter.string(from: newTime))"
                                            )

                                            // Debug the current time before update
                                            if let currentTime = placeInput.startTime {
                                                print(
                                                    "⏰ Current start time is \(formatter.string(from: currentTime))"
                                                )
                                            } else {
                                                print("⏰ Current start time is nil")
                                            }

                                            // Save state before changing time
                                            viewModel.saveStateBeforeEdit()

                                            placeInput.startTime = newTime

                                            print(
                                                "⏰ After update, placeInput.startTime = \(placeInput.startTime.map { formatter.string(from: $0) } ?? "nil")"
                                            )

                                            // Check for overlaps after updating the time
                                            viewModel.checkForTimeOverlaps()
                                        }
                                    ), displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                            }

                            Spacer()

                            VStack(alignment: .leading, spacing: 4) {
                                Text("End Time")
                                    .font(themeManager.selectedTheme.captionTextFont)
                                    .foregroundColor(themeManager.selectedTheme.secondaryColor)

                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: {
                                            if let time = placeInput.endTime {
                                                return time
                                            } else {
                                                // Default to 11:00 AM (2 hours after start)
                                                let calendar = Calendar.current
                                                var components = calendar.dateComponents(
                                                    [.year, .month, .day], from: Date())
                                                components.hour = 11
                                                components.minute = 0
                                                return calendar.date(from: components)
                                                    ?? Date().addingTimeInterval(3600)
                                            }
                                        },
                                        set: { newTime in
                                            let formatter = DateFormatter()
                                            formatter.dateFormat = "HH:mm:ss"
                                            print(
                                                "⏰ End time picker changed to \(formatter.string(from: newTime))"
                                            )

                                            // Debug the current time before update
                                            if let currentTime = placeInput.endTime {
                                                print(
                                                    "⏰ Current end time is \(formatter.string(from: currentTime))"
                                                )
                                            } else {
                                                print("⏰ Current end time is nil")
                                            }

                                            // Save state before changing time
                                            viewModel.saveStateBeforeEdit()

                                            placeInput.endTime = newTime

                                            print(
                                                "⏰ After update, placeInput.endTime = \(placeInput.endTime.map { formatter.string(from: $0) } ?? "nil")"
                                            )

                                            // Check for overlaps after updating the time
                                            viewModel.checkForTimeOverlaps()
                                        }
                                    ), displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                            }
                        }

                        // Notes
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(themeManager.selectedTheme.captionTextFont)
                                .foregroundColor(themeManager.selectedTheme.secondaryColor)

                            TextField(
                                "Optional notes",
                                text: Binding(
                                    get: { placeInput.notes ?? "" },
                                    set: {
                                        // Save state before changing notes
                                        viewModel.saveStateBeforeEdit()
                                        placeInput.notes = $0
                                    }
                                )
                            )
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }

                        // Remove button
                        Button(action: onRemove) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Remove")
                            }
                            .foregroundColor(themeManager.selectedTheme.warningColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 8)
            } else {
                // Place selection - use the old way if no place is selected yet
                VStack(alignment: .leading, spacing: 4) {
                    Text("Place")
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundColor(themeManager.selectedTheme.secondaryColor)

                    if isLoading {
                        HStack {
                            ProgressView()
                            Text("Loading places...")
                        }
                        .padding(.vertical, 8)
                    } else {
                        Menu {
                            ForEach(availablePlaces, id: \.id) { place in
                                Button(place.name) {
                                    placeInput.placeId = place.id
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedPlaceName)
                                    .foregroundColor(
                                        placeInput.placeId == nil
                                            ? .gray : themeManager.selectedTheme.primaryColor)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }
                    }
                }
            }

        }
        .padding(.horizontal)
        // Use the wrapper with sheet presentation
        .sheet(isPresented: $showOpeningHours) {
            print("ℹ️ Sheet dismissed")
        } content: {
            if let place = selectedPlace {
                OpeningHoursSheetWrapper(
                    placeId: place.id,
                    isPresented: $showOpeningHours
                )
                .environmentObject(themeManager)
            }
        }
        .onAppear {
            print("🔄 PlaceInputRow appeared - placeId: \(placeInput.placeId ?? "nil")")
        }
        .onDisappear {
            print("🔄 PlaceInputRow disappeared - placeId: \(placeInput.placeId ?? "nil")")
        }
    }

    private var selectedPlaceName: String {
        if let placeId = placeInput.placeId {
            return availablePlaces.first(where: { $0.id == placeId })?.name ?? "Unknown Place"
        } else {
            return "Select a place"
        }
    }
}
