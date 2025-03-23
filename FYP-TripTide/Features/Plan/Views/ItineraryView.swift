import SwiftUI

struct ItineraryView: View {
    @EnvironmentObject private var themeManager: ThemeManager
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
                                        .stroke(
                                            themeManager.selectedTheme.primaryColor, lineWidth: 1)
                                )

                            Spacer()

                            NavigationLink(
                                // TODO: Change to EditItineraryView
                                destination: EditItineraryView(
                                    tripId: viewModel.tripId, day: dayItinerary.dayNumber,
                                    numberOfDays: viewModel.numberOfDays,
                                    isEditing: true
                                )
                            ) {
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
                        NavigationLink(
                            destination: EditItineraryView(
                                tripId: viewModel.tripId, day: viewModel.selectedDayIndex + 1,
                                numberOfDays: viewModel.numberOfDays)
                        ) {
                            Text("Create Itinerary")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                }
            } else {
                VStack {
                    ContentUnavailableView(
                        "No Itinerary Found",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("This trip doesn't have an itinerary yet.")
                    )

                    NavigationLink(destination: EditItineraryView(tripId: viewModel.tripId, day: viewModel.selectedDayIndex + 1, numberOfDays: viewModel.numberOfDays)) {
                        Text("Create Itinerary")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
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
        .tint(themeManager.selectedTheme.accentColor)
        .background(themeManager.selectedTheme.appBackgroundColor)
        .cornerRadius(12)
        .onAppear {
            Task {
                await viewModel.refreshItineraryData()
            }
        }
    }
}
