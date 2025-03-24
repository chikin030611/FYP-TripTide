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
        NavigationLink(destination: ScheduledPlaceDetailView(viewModel: ScheduledPlaceDetailViewModel(scheduledPlace: viewModel.scheduledPlace))) {
            HStack(spacing: 12) {
                // Time column
                VStack(alignment: .trailing, spacing: 4) {
                    if viewModel.hasStartAndEndTime,
                        let startTime = viewModel.startTime,
                        let endTime = viewModel.endTime
                    {
                        HStack {
                            Image(systemName: "clock")
                                .font(themeManager.selectedTheme.bodyTextFont)
                                .foregroundColor(themeManager.selectedTheme.secondaryColor)

                            VStack {
                                Text(viewModel.formatTime(startTime))
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    .foregroundColor(themeManager.selectedTheme.primaryColor)

                                Text(" - ")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    .foregroundColor(themeManager.selectedTheme.secondaryColor)

                                Text(viewModel.formatTime(endTime))
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                            }
                        }
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
                        ZStack {
                            AsyncImageView(imageUrl: viewModel.placeImage, width: 250, height: 125)
                                .cornerRadius(10)

                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.black.opacity(0.01), Color.black.opacity(0.35),
                                        ]),
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                                .frame(width: 250, height: 125, alignment: .topLeading)

                            VStack(alignment: .leading, spacing: 4) {
                                ZStack {
                                    Text(viewModel.placeType.formatTagName())
                                        .font(themeManager.selectedTheme.captionTextFont)
                                        .foregroundColor(themeManager.selectedTheme.bgTextColor)
                                }
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(themeManager.selectedTheme.accentColor)
                                )

                                Text(viewModel.placeName)
                                    .font(themeManager.selectedTheme.boldBodyTextFont)
                                    .foregroundColor(themeManager.selectedTheme.bgTextColor)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(alignment: .bottomLeading)

                                if let notes = viewModel.notes, !notes.isEmpty {
                                    Text(notes)
                                        .font(themeManager.selectedTheme.captionTextFont)
                                        .foregroundColor(themeManager.selectedTheme.bgTextColor)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.8)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(alignment: .bottomLeading)
                                }
                            }
                            .frame(width: 240, height: 115, alignment: .topLeading)
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
                viewModel.loadPlaceDetails()
            }
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