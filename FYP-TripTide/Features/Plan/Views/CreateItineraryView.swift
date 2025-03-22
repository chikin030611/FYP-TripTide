import SwiftUI
import UniformTypeIdentifiers

struct CreateItineraryView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject var viewModel: CreateItineraryViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: Int = 0

    init(tripId: String, day: Int, numberOfDays: Int) {
        let vm = CreateItineraryViewModel(tripId: tripId, day: day, numberOfDays: numberOfDays)
        self._viewModel = ObservedObject(wrappedValue: vm)
    }

    var body: some View {
        VStack(spacing: 20) {
            // Extract this to a separate view
            DayButtonsView(
                numberOfDays: viewModel.numberOfDays,
                selectedDayIndex: viewModel.day - 1,
                onSelectDay: { index in
                    viewModel.day = index + 1
                }
            )

            // Custom Tab Bar
            HStack(spacing: 0) {
                TabButton(title: "Tourist Attractions", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }

                TabButton(title: "Restaurants", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }

                TabButton(title: "Lodging", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
            }
            .padding(.horizontal)

            TabView(selection: $selectedTab) {
                // Tourist Attractions Tab
                if viewModel.isLoadingPlaces {
                    ProgressView("Loading tourist attractions...")
                        .tag(0)
                } else if viewModel.touristAttractions.isEmpty {
                    ContentUnavailableView(
                        "No Tourist Attractions",
                        systemImage: "mappin.and.ellipse",
                        description: Text("No tourist attractions have been saved to this trip")
                    )
                    .tag(0)
                } else {
                    DragAndDropCardGroup(places: viewModel.touristAttractions)
                        .tag(0)
                }
                
                // Restaurants Tab
                if viewModel.isLoadingPlaces {
                    ProgressView("Loading restaurants...")
                        .tag(1)
                } else if viewModel.restaurants.isEmpty {
                    ContentUnavailableView(
                        "No Restaurants",
                        systemImage: "fork.knife",
                        description: Text("No restaurants have been saved to this trip")
                    )
                    .tag(1)
                } else {
                    DragAndDropCardGroup(places: viewModel.restaurants)
                        .tag(1)
                }
                
                // Lodging Tab
                if viewModel.isLoadingPlaces {
                    ProgressView("Loading lodgings...")
                        .tag(2)
                } else if viewModel.lodgings.isEmpty {
                    ContentUnavailableView(
                        "No Lodgings",
                        systemImage: "bed.double",
                        description: Text("No lodgings have been saved to this trip")
                    )
                    .tag(2)
                } else {
                    DragAndDropCardGroup(places: viewModel.lodgings)
                        .tag(2)
                }
            }
            .frame(height: 125)
            .tabViewStyle(.page(indexDisplayMode: .never))

            Divider()
                .padding(.horizontal)
                
            // Drop area for cards
            DropTargetArea(viewModel: viewModel)
                .padding(.horizontal)

            ScrollView {
                VStack(spacing: 24) {
                    // Places List
                    ForEach(viewModel.scheduledPlaces.indices, id: \.self) { index in
                        PlaceInputRow(
                            placeInput: viewModel.scheduledPlaces[index],
                            availablePlaces: viewModel.availablePlaces,
                            isLoading: viewModel.isLoadingPlaces,
                            onRemove: {
                                viewModel.removePlaceAt(index: index)
                            }
                        )
                        .id(viewModel.scheduledPlaces[index].id)

                        if index < viewModel.scheduledPlaces.count - 1 {
                            Divider()
                                .padding(.horizontal)
                        }
                    }

                    // Add Place Button
                    Button(action: {
                        viewModel.addPlace()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Place")
                        }
                        .foregroundColor(themeManager.selectedTheme.accentColor)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)

            // Error message
            if let error = viewModel.error {
                Text(error)
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundColor(themeManager.selectedTheme.warningColor)
                    .padding(.horizontal)
            }

            // Action Buttons
            HStack {
                Button("Save Itinerary") {
                    Task {
                        await viewModel.saveItinerary()
                        if viewModel.isSuccess {
                            dismiss()
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.isLoading)

                if viewModel.isLoading {
                    ProgressView()
                        .padding(.leading, 8)
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.loadAvailablePlaces()
        }
        .background(themeManager.selectedTheme.appBackgroundColor)
        .tint(themeManager.selectedTheme.accentColor)
        .navigationTitle("Create Itinerary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// New separate view for day buttons
struct DayButtonsView: View {
    let numberOfDays: Int
    let selectedDayIndex: Int
    let onSelectDay: (Int) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(0..<numberOfDays, id: \.self) { index in
                    DayButton(
                        dayIndex: index,
                        isSelected: selectedDayIndex == index,
                        onSelect: {
                            onSelectDay(index)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct PlaceInputRow: View {
    @ObservedObject var placeInput: ScheduledPlaceInput
    let availablePlaces: [Place]
    let isLoading: Bool
    let onRemove: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Place selection
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
                            get: { placeInput.endTime ?? Date().addingTimeInterval(3600) },
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

// Drop target area for accepting cards
struct DropTargetArea: View {
    @ObservedObject var viewModel: CreateItineraryViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var isTargeted = false
    
    var body: some View {
        VStack {
            Text("Drag cards here to add to itinerary")
                .font(themeManager.selectedTheme.captionTextFont)
                .foregroundColor(themeManager.selectedTheme.secondaryColor)
                .padding(.vertical, 8)
            
            Image(systemName: "arrow.down.doc.fill")
                .font(.system(size: 24))
                .foregroundColor(themeManager.selectedTheme.accentColor)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(isTargeted ? 0.2 : 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(themeManager.selectedTheme.accentColor, lineWidth: isTargeted ? 2 : 1)
                        .opacity(isTargeted ? 0.8 : 0.5)
                )
        )
        .onDrop(of: [UTType.text.identifier], isTargeted: $isTargeted) { providers, _ in
            guard let provider = providers.first else { return false }
            
            provider.loadObject(ofClass: NSString.self) { object, error in
                guard error == nil else {
                    print("Error loading object: \(error!.localizedDescription)")
                    return
                }
                
                if let placeId = object as? String {
                    DispatchQueue.main.async {
                        // Add new place to the itinerary with the dropped place ID
                        let newPlace = ScheduledPlaceInput()
                        newPlace.placeId = placeId
                        viewModel.scheduledPlaces.append(newPlace)
                    }
                }
            }
            
            return true
        }
        .animation(.easeInOut(duration: 0.2), value: isTargeted)
    }
}
