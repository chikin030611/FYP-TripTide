import SwiftUI

struct ItineraryView: View {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var viewModel: ItineraryViewModel
    @Environment(\.dismiss) private var dismiss

    init(dailyItineraries: [DailyItinerary]?, numberOfDays: Int, tripId: String) {
        self._viewModel = StateObject(
            wrappedValue: ItineraryViewModel(
                dailyItineraries: dailyItineraries,
                numberOfDays: numberOfDays,
                tripId: tripId
            ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            if let itineraries = viewModel.dailyItineraries, !itineraries.isEmpty {
                // Days picker - moved up and full width
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(0..<viewModel.numberOfDays, id: \.self) { index in
                            DayButton(
                                dayIndex: index,
                                isSelected: viewModel.selectedDayIndex == index,
                                onSelect: {
                                    viewModel.selectDay(index: index)
                                })
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)

                if let dayItinerary = viewModel.selectedDayItinerary {
                    if let date = dayItinerary.date {
                        HStack {
                            Text(date.formatted(date: .long, time: .omitted))
                                .font(themeManager.selectedTheme.titleFont)
                                .foregroundColor(themeManager.selectedTheme.primaryColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(themeManager.selectedTheme.primaryColor, lineWidth: 1)
                                )

                            Spacer()

                            NavigationLink(destination: CreateItineraryView(tripId: viewModel.tripId, day: dayItinerary.dayNumber, totalDays: viewModel.numberOfDays)) {
                                HStack(spacing: 2) {
                                    Image(systemName: "pencil")
                                    .foregroundStyle(themeManager.selectedTheme.secondaryColor)
                                    .font(themeManager.selectedTheme.titleFont)
                                Text("Edit")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Selected day's scheduled places
                    // Check if places array exists and has items
                    let places = dayItinerary.places
                    if places.count > 0 {
                        ScrollView {
                            ForEach(places) { place in
                                ScheduledPlaceView(scheduledPlace: place)
                                    .padding(.horizontal)
                            }
                        }
                    }
                } else {
                    // Show when the selected day has no itinerary data
                    VStack {
                        ContentUnavailableView(
                            "No Itinerary for Day \(viewModel.selectedDayIndex + 1)",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("This day doesn't have any scheduled activities yet.")
                        )
                        NavigationLink(destination: CreateItineraryView(tripId: viewModel.tripId, day: viewModel.selectedDayIndex + 1, totalDays: viewModel.numberOfDays)) {
                            Text("Create Itinerary")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
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
        .navigationTitle("Itinerary")
        .navigationBarItems(
            leading:
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
        )
        .accentColor(themeManager.selectedTheme.accentColor)
        .background(themeManager.selectedTheme.appBackgroundColor)
        .cornerRadius(12)
        .onAppear {
            Task {
                await viewModel.refreshItineraryData()
            }
        }
    }
}

// Sub-view for each scheduled place
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

struct DayButton: View {
    let dayIndex: Int
    let isSelected: Bool
    let onSelect: () -> Void
    @StateObject private var themeManager = ThemeManager()

    var body: some View {
        Button(action: {
            onSelect()
        }) {
            VStack {
                Text("Day")
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundColor(
                        isSelected
                            ? themeManager.selectedTheme.bgTextColor
                            : themeManager.selectedTheme.secondaryColor)
                Text("\(dayIndex + 1)")
                    .font(themeManager.selectedTheme.titleFont)
                    .foregroundColor(
                        isSelected
                            ? themeManager.selectedTheme.bgTextColor
                            : themeManager.selectedTheme.secondaryColor)

            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        isSelected
                            ? themeManager.selectedTheme.accentColor
                            : themeManager.selectedTheme.backgroundColor)
            )
            .foregroundColor(
                isSelected ? .white : themeManager.selectedTheme.primaryColor
            )
        }
    }
}
