import SwiftUI

struct PlaceInputRow: View {
    @ObservedObject var placeInput: ScheduledPlaceInput
    let availablePlaces: [Place]
    let isLoading: Bool
    let onRemove: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

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

                        // Times
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Start Time")
                                    .font(themeManager.selectedTheme.captionTextFont)
                                    .foregroundColor(themeManager.selectedTheme.secondaryColor)

                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { placeInput.startTime ?? Date() },
                                        set: { placeInput.startTime = $0 }
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
                                            placeInput.endTime ?? Date().addingTimeInterval(3600)
                                        },
                                        set: { placeInput.endTime = $0 }
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
                                    set: { placeInput.notes = $0 }
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
    }

    private var selectedPlaceName: String {
        if let placeId = placeInput.placeId {
            return availablePlaces.first(where: { $0.id == placeId })?.name ?? "Unknown Place"
        } else {
            return "Select a place"
        }
    }
}
