import SwiftUI

struct CreateItineraryView: View {
    @StateObject private var themeManager = ThemeManager()
    @ObservedObject var viewModel: CreateItineraryViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(tripId: String, day: Int, totalDays: Int) {
        let vm = CreateItineraryViewModel(tripId: tripId, day: day, totalDays: totalDays)
        self._viewModel = ObservedObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Create Itinerary for Day \(viewModel.day)")
                    .font(themeManager.selectedTheme.titleFont)
                    .foregroundColor(themeManager.selectedTheme.primaryColor)
                
                Spacer()
                
                Picker("Day", selection: $viewModel.day) {
                    ForEach(1...5, id: \.self) { day in
                        Text("Day \(day)").tag(day)
                    }
                }
                .pickerStyle(.menu)
                .foregroundColor(themeManager.selectedTheme.accentColor)
            }
            .padding(.horizontal)
            
            Divider()
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
                .padding(.vertical)
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
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Spacer()
                
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
        .navigationTitle("Create Itinerary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlaceInputRow: View {
    @ObservedObject var placeInput: ScheduledPlaceInput
    let availablePlaces: [PlaceBasicData]
    let isLoading: Bool
    let onRemove: () -> Void
    @StateObject private var themeManager = ThemeManager()
    
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
                        ForEach(availablePlaces, id: \.placeId) { place in
                            Button(place.name) {
                                placeInput.placeId = place.placeId
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedPlaceName)
                                .foregroundColor(placeInput.placeId == nil ? .gray : themeManager.selectedTheme.primaryColor)
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
                    
                    DatePicker("", selection: Binding(
                        get: { placeInput.startTime ?? Date() },
                        set: { placeInput.startTime = $0 }
                    ), displayedComponents: .hourAndMinute)
                    .labelsHidden()
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("End Time")
                        .font(themeManager.selectedTheme.captionTextFont)
                        .foregroundColor(themeManager.selectedTheme.secondaryColor)
                    
                    DatePicker("", selection: Binding(
                        get: { placeInput.endTime ?? Date().addingTimeInterval(3600) },
                        set: { placeInput.endTime = $0 }
                    ), displayedComponents: .hourAndMinute)
                    .labelsHidden()
                }
            }
            
            // Notes
            VStack(alignment: .leading, spacing: 4) {
                Text("Notes")
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
                
                TextField("Optional notes", text: Binding(
                    get: { placeInput.notes ?? "" },
                    set: { placeInput.notes = $0 }
                ))
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
            return availablePlaces.first(where: { $0.placeId == placeId })?.name ?? "Unknown Place"
        } else {
            return "Select a place"
        }
    }
}

#Preview {
    NavigationStack {
        CreateItineraryView(tripId: "test-trip-id", day: 1, totalDays: 5)
    }
} 