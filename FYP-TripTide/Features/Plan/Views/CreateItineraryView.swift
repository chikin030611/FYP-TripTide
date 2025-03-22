import SwiftUI
import UniformTypeIdentifiers

struct CreateItineraryView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject var viewModel: CreateItineraryViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: Int = 0
    @State private var isDraggingCards = false

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
            .padding(.vertical, -8)

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

            ZStack {
                // Drop area for cards
                DropTargetArea(viewModel: viewModel)
                    .padding()
                    // When any dragging operation starts, show the drop area
                    .onChange(
                        of: isDraggingCards,
                        perform: { newValue in
                            if newValue {
                                withAnimation {
                                    viewModel.showDropArea = true
                                }
                            }
                        })

                ScrollView {
                    VStack(spacing: 24) {
                        // Places List
                        if !viewModel.showDropArea {
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

                        }
                    }
                }
                .padding(.vertical)
                .contentShape(Rectangle())
                .onDrop(of: [UTType.text.identifier], isTargeted: $isDraggingCards) {
                    providers, _ in
                    // This acts as a general drop handler and drag state monitor
                    // Forward the drop to appropriate handler
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

                                // Hide the drop area after successful drop
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.showDropArea = false
                                }
                            }
                        }
                    }

                    return true
                }
            }

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
            Task {
                await viewModel.loadAvailablePlaces()
            }
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
                    CompactDayButton(
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

// Drop target area for accepting cards
struct DropTargetArea: View {
    @ObservedObject var viewModel: CreateItineraryViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var isTargeted = false
    // Add a timer to track when drag operations end
    @State private var dragEndTimer: Timer? = nil

    var body: some View {
        // Single container with drop functionality
        ZStack {
            // Visual elements - only shown when showDropArea is true or being targeted
            if viewModel.showDropArea || isTargeted {
                VStack {
                    Text("Hold and drag cards here to add to itinerary")
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundColor(themeManager.selectedTheme.secondaryColor)
                        .padding(.vertical, 8)

                    Image(systemName: "arrow.down.doc.fill")
                        .font(.system(size: 36))
                        .foregroundColor(themeManager.selectedTheme.secondaryColor)
                        .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity, minHeight: 280)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            themeManager.selectedTheme.appBackgroundColor.opacity(
                                isTargeted ? 0.2 : 0.1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    themeManager.selectedTheme.secondaryColor,
                                    lineWidth: isTargeted ? 2 : 1
                                )
                                .opacity(isTargeted ? 0.8 : 0.5)
                        )
                )
            } else {
                // Empty spacer when not showing drop area
                Spacer().frame(height: 0)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: viewModel.showDropArea || isTargeted ? 280 : 40)
        .opacity(viewModel.showDropArea || isTargeted ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.2), value: viewModel.showDropArea)
        .animation(.easeInOut(duration: 0.2), value: isTargeted)
        .contentShape(Rectangle())
        .onChange(
            of: isTargeted,
            perform: { newValue in
                // When the target state changes
                if newValue {
                    // Cancel any pending timer when a new drag enters
                    dragEndTimer?.invalidate()
                } else {
                    // When drag leaves the area, start a timer
                    // This gives time for the drop operation to complete if it's going to
                    dragEndTimer?.invalidate()
                    dragEndTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {
                        _ in
                        // If this timer fires, it means no drop occurred after leaving the target area
                        // Hide the drop area if it was only showing because of targeting
                        if !viewModel.scheduledPlaces.isEmpty {
                            withAnimation {
                                viewModel.showDropArea = false
                            }
                        }
                    }
                }
            }
        )
        .onDrop(of: [UTType.text.identifier], isTargeted: $isTargeted) { providers, _ in
            // Cancel the timer because a drop occurred
            dragEndTimer?.invalidate()

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

                        // Hide the drop area after successful drop
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.showDropArea = false
                        }
                    }
                }
            }

            return true
        }
    }
}
