import SwiftUI
import UniformTypeIdentifiers

struct EditItineraryView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel: EditItineraryViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: Int = 0
    @State private var isDraggingCards = false

    init(tripId: String, day: Int, numberOfDays: Int, isEditing: Bool = false) {
        print("⚠️ EditItineraryView init - tripId: \(tripId), day: \(day)")
        let vm = EditItineraryViewModel(
            tripId: tripId,
            day: day,
            numberOfDays: numberOfDays,
            isEditing: isEditing
        )
        _viewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        MainContentView(
            viewModel: viewModel,
            selectedTab: $selectedTab,
            isDraggingCards: $isDraggingCards,
            dismiss: dismiss
        )
        .onAppear {
            print("⚠️ EditItineraryView onAppear")
            Task {
                await viewModel.loadAvailablePlaces()
            }
        }
        .onDisappear {
            print("⚠️ EditItineraryView onDisappear")
        }
        .background(themeManager.selectedTheme.appBackgroundColor)
        .tint(themeManager.selectedTheme.accentColor)
        .navigationTitle(viewModel.isEditing ? "Edit Itinerary" : "Create Itinerary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Add this new struct before the EditItineraryView
struct MainContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject var viewModel: EditItineraryViewModel
    @Binding var selectedTab: Int
    @Binding var isDraggingCards: Bool
    let dismiss: DismissAction
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 12) {
            DayButtonsView(
                numberOfDays: viewModel.numberOfDays,
                selectedDayIndex: viewModel.day - 1,
                onSelectDay: { index in
                    viewModel.day = index + 1
                }
            )

            // Display the date for the selected day
            if let date = viewModel.selectedDate {
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

                    // Add undo button
                    if viewModel.canUndo {
                        Button {
                            viewModel.undo()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.uturn.backward")
                                Text("Undo")
                            }
                        }
                        .buttonStyle(SecondaryTagButtonStyle())
                    }
                }
                .padding(.horizontal)
            }

            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    TabBarView(selectedTab: $selectedTab)

                    PlacesTabView(
                        viewModel: viewModel,
                        selectedTab: selectedTab
                    )
                },
                label: {
                    Text("Available Places")
                        .font(themeManager.selectedTheme.titleFont)
                        .foregroundColor(themeManager.selectedTheme.primaryColor)
                }
            )
            .padding(.horizontal)

            PlacesDropArea(
                viewModel: viewModel,
                isDraggingCards: $isDraggingCards
            )

            if let error = viewModel.error {
                ErrorMessageView(error: error)
            }

            if !viewModel.timeOverlapWarnings.isEmpty {
                TimeOverlapWarningsView(warnings: viewModel.timeOverlapWarnings)
            }

            if !viewModel.invalidTimeRangeWarnings.isEmpty {
                InvalidTimeRangeWarningsView(warnings: viewModel.invalidTimeRangeWarnings)
            }

            if viewModel.isEditing && viewModel.scheduledPlaces.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(themeManager.selectedTheme.warningColor)
                    Text("All places removed. Press 'Preview Changes' to confirm deletion.")
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundColor(themeManager.selectedTheme.warningColor)
                }
                .padding()
                .background(themeManager.selectedTheme.warningColor.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            }

            ActionButtonsView(
                viewModel: viewModel,
                dismiss: dismiss
            )
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
            }
            .foregroundColor(themeManager.selectedTheme.primaryColor)
        }
    }

}

struct TabBarView: View {
    @Binding var selectedTab: Int

    var body: some View {
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
        .padding(.vertical, -2)
    }
}

struct PlacesTabView: View {
    @ObservedObject var viewModel: EditItineraryViewModel
    let selectedTab: Int

    var body: some View {
        TabView(selection: .constant(selectedTab)) {
            PlacesListView(
                isLoading: viewModel.isLoadingPlaces,
                places: viewModel.touristAttractions,
                emptyMessage: "No Tourist Attractions",
                emptyDescription: "No tourist attractions have been saved to this trip",
                emptyIcon: "mappin.and.ellipse"
            )
            .tag(0)

            PlacesListView(
                isLoading: viewModel.isLoadingPlaces,
                places: viewModel.restaurants,
                emptyMessage: "No Restaurants",
                emptyDescription: "No restaurants have been saved to this trip",
                emptyIcon: "fork.knife"
            )
            .tag(1)

            PlacesListView(
                isLoading: viewModel.isLoadingPlaces,
                places: viewModel.lodgings,
                emptyMessage: "No Lodgings",
                emptyDescription: "No lodgings have been saved to this trip",
                emptyIcon: "bed.double"
            )
            .tag(2)
        }
        .frame(height: 125)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct PlacesListView: View {
    let isLoading: Bool
    let places: [Place]
    let emptyMessage: String
    let emptyDescription: String
    let emptyIcon: String

    var body: some View {
        if isLoading {
            ProgressView("Loading...")
        } else if places.isEmpty {
            ContentUnavailableView(
                emptyMessage,
                systemImage: emptyIcon,
                description: Text(emptyDescription)
            )
        } else {
            DragAndDropCardGroup(places: places)
        }
    }
}

struct PlacesDropArea: View {
    @ObservedObject var viewModel: EditItineraryViewModel
    @Binding var isDraggingCards: Bool

    var body: some View {
        ZStack {
            DropTargetArea(viewModel: viewModel)
                .padding()
                .onChange(of: isDraggingCards) { _, newValue in
                    if newValue {
                        withAnimation {
                            viewModel.showDropArea = true
                        }
                    }
                }

            ScrollView {
                VStack(spacing: 24) {
                    if !viewModel.showDropArea {
                        ForEach(viewModel.scheduledPlaces.indices, id: \.self) { index in
                            PlaceInputRow(
                                placeInput: viewModel.scheduledPlaces[index],
                                availablePlaces: viewModel.availablePlaces,
                                isLoading: viewModel.isLoadingPlaces,
                                onRemove: {
                                    viewModel.removePlaceAt(index: index)
                                },
                                viewModel: viewModel
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
            .onDrop(of: [UTType.text.identifier], isTargeted: $isDraggingCards) { providers, _ in
                guard let provider = providers.first else { return false }

                provider.loadObject(ofClass: NSString.self) { object, error in
                    guard error == nil else {
                        print("Error loading object: \(error!.localizedDescription)")
                        return
                    }

                    if let placeId = object as? String {
                        Task { @MainActor in
                            viewModel.addPlaceWithId(placeId)
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
}

struct ErrorMessageView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let error: String

    var body: some View {
        Text(error)
            .font(themeManager.selectedTheme.captionTextFont)
            .foregroundColor(themeManager.selectedTheme.warningColor)
            .padding(.horizontal)
    }
}

struct TimeOverlapWarningsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let warnings: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(warnings, id: \.self) { warning in
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(themeManager.selectedTheme.warningColor)
                    Text(warning)
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundColor(themeManager.selectedTheme.warningColor)
                }
                .padding(.horizontal)
            }
        }
        .background(themeManager.selectedTheme.warningColor.opacity(0.1))
    }
}

struct InvalidTimeRangeWarningsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let warnings: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(warnings, id: \.self) { warning in
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(themeManager.selectedTheme.warningColor)
                    Text(warning)
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundColor(themeManager.selectedTheme.warningColor)
                }
                .padding(.horizontal)
            }
        }
        .padding(8)
        .background(themeManager.selectedTheme.warningColor.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct ActionButtonsView: View {
    @ObservedObject var viewModel: EditItineraryViewModel
    let dismiss: DismissAction
    @State private var showPreview = false
    @State private var previewViewModel: EditItineraryViewModel? = nil

    var body: some View {
        HStack {
            Button(viewModel.isEditing ? "Preview Changes" : "Preview Itinerary") {
                print("🔘 Preview button clicked")

                // Force update dictionary before creating preview
                viewModel.forceUpdateDictionaryForCurrentDay()

                // Create a preview copy
                previewViewModel = viewModel.createPreviewCopy()

                // Debug output
                print(
                    "📋 Created preview model with isPreviewMode=\(previewViewModel?.isPreviewMode ?? false)"
                )

                showPreview = true
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(
                viewModel.isLoading || !viewModel.timeOverlapWarnings.isEmpty
                    || !viewModel.invalidTimeRangeWarnings.isEmpty
            )
            .opacity(
                (!viewModel.timeOverlapWarnings.isEmpty
                    || !viewModel.invalidTimeRangeWarnings.isEmpty) ? 0.7 : 1.0
            )
            .sheet(isPresented: $showPreview) {
                if let previewVM = previewViewModel {
                    ItineraryPreviewView(
                        viewModel: previewVM,
                        onConfirm: {
                            // Copy data from preview model back to original model before saving
                            viewModel.scheduledPlaces = previewVM.scheduledPlaces
                            viewModel.scheduledPlacesByDay = previewVM.scheduledPlacesByDay

                            // IMPORTANT: Make sure we're saving to the current day, not the original day
                            // This is the key fix - ensure the day value is properly transferred
                            viewModel.day = previewVM.day

                            // Update existingItineraryId to match the current day
                            if let itinerary = viewModel.allItineraries.first(where: {
                                $0.dayNumber == viewModel.day
                            }) {
                                viewModel.existingItineraryId = itinerary.id
                            } else {
                                viewModel.existingItineraryId = nil
                            }

                            Task {
                                await viewModel.saveItinerary()
                                if viewModel.isSuccess {
                                    dismiss()
                                }
                            }
                        },
                        onCancel: {
                            showPreview = false
                        }
                    )
                }
            }

            if viewModel.isLoading {
                ProgressView()
                    .padding(.leading, 8)
            }
        }
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
    @ObservedObject var viewModel: EditItineraryViewModel
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
                        // Use the new method that handles dictionary updates
                        viewModel.addPlaceWithId(placeId)

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
