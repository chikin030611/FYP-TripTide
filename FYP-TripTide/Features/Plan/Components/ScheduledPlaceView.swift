import SwiftUI

struct ScheduledPlaceView: View {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var viewModel: ScheduledPlaceViewModel

    init(scheduledPlace: ScheduledPlace) {
        self._viewModel = StateObject(
            wrappedValue: ScheduledPlaceViewModel(
                scheduledPlace: scheduledPlace
            ))
    }

    var body: some View {
        HStack(spacing: 12) {
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading place details...")
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundColor(themeManager.selectedTheme.secondaryColor)
                }
            } else if let error = viewModel.loadingError {
                VStack(alignment: .leading) {
                    Text("Error loading place")
                        .font(themeManager.selectedTheme.bodyTextFont)
                        .foregroundColor(themeManager.selectedTheme.primaryColor)
                    Text(error)
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundColor(themeManager.selectedTheme.warningColor)
                }
            } else {
                AsyncImageView(imageUrl: viewModel.placeImage, width: 140, height: 120)
                    .cornerRadius(10)

                // Vertical line
                Rectangle()
                    .fill(themeManager.selectedTheme.accentColor)
                    .frame(width: 2)
                    .padding(.vertical, 4)

                // Place details
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.placeType.formatTagName())
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundColor(themeManager.selectedTheme.bgTextColor)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(themeManager.selectedTheme.accentColor)
                        )

                    Text(viewModel.placeName)
                        .font(themeManager.selectedTheme.boldBodyTextFont)
                        .foregroundColor(themeManager.selectedTheme.primaryColor)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(alignment: .bottomLeading)

                    if viewModel.hasStartAndEndTime,
                        let startTime = viewModel.startTime,
                        let endTime = viewModel.endTime
                    {
                        HStack {
                            Image(systemName: "clock")
                                .font(themeManager.selectedTheme.bodyTextFont)
                                .foregroundColor(themeManager.selectedTheme.secondaryColor)

                            VStack {
                                Text(
                                    "\(viewModel.formatTime(startTime)) - \(viewModel.formatTime(endTime))"
                                )
                                .font(themeManager.selectedTheme.bodyTextFont)
                                .foregroundColor(themeManager.selectedTheme.primaryColor)
                            }
                        }
                    } else {
                        Text("No time")
                            .font(themeManager.selectedTheme.captionTextFont)
                            .foregroundColor(themeManager.selectedTheme.secondaryColor)
                    }

                    if let notes = viewModel.notes, !notes.isEmpty {
                        VStack(alignment: .leading) {
                            DisclosureGroup(
                                content: {
                                    Text(notes)
                                        .font(themeManager.selectedTheme.bodyTextFont)
                                        .foregroundColor(themeManager.selectedTheme.secondaryColor)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                },
                                label: {
                                    Text("Notes")
                                        .font(themeManager.selectedTheme.bodyTextFont)
                                        .foregroundColor(
                                            themeManager.selectedTheme.secondaryColor)
                                })
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .onAppear {
            viewModel.loadPlaceDetails()
        }
    }
}

class ScheduledPlaceViewModel: ObservableObject {
    private let placesService = PlacesService.shared
    let scheduledPlace: ScheduledPlace

    @Published var placeName: String = "Loading..."
    @Published var placeImage: String = "placeholder"
    @Published var placeType: String = "Loading..."
    @Published var isLoading: Bool = true
    @Published var loadingError: String? = nil
    @Published var isPlaceLoaded: Bool = false

    init(scheduledPlace: ScheduledPlace) {
        self.scheduledPlace = scheduledPlace
    }

    var hasStartAndEndTime: Bool {
        return scheduledPlace.startTime != nil && scheduledPlace.endTime != nil
    }

    var date: Date? {
        return scheduledPlace.date
    }

    var startTime: Date? {
        return scheduledPlace.startTime
    }

    var endTime: Date? {
        return scheduledPlace.endTime
    }

    var notes: String? {
        return scheduledPlace.notes
    }

    func loadPlaceDetails() {
        // Don't reload if already loaded
        if isPlaceLoaded { return }

        Task {
            self.isLoading = true
            self.loadingError = nil

            do {
                // Try to fetch place basic data
                let placeData = try await placesService.fetchPlaceBasicById(
                    id: scheduledPlace.placeId)

                await MainActor.run {
                    self.placeName = placeData.name
                    self.placeType = placeData.type.formatTagName()
                    // Make sure photoUrl is not empty
                    if !placeData.photoUrl.isEmpty {
                        self.placeImage = placesService.appendAPIKey(to: placeData.photoUrl)
                    }
                    self.isLoading = false
                    self.isPlaceLoaded = true
                }
            } catch {
                await MainActor.run {
                    self.placeName = "Failed to load"
                    self.placeType = "Failed to load"
                    self.isLoading = false
                    self.loadingError = "Could not load place data"
                    print("Error loading place details: \(error)")
                }
            }
        }
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
