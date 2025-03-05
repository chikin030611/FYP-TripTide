import SwiftUI

struct EditTripView: View {
    @StateObject private var viewModel: EditTripViewModel
    @StateObject private var themeManager = ThemeManager()
    @Environment(\.presentationMode) private var presentationMode
    @Binding var navigationPath: NavigationPath
    @State private var showCancelAlert: Bool = false
    @State private var showToast: Bool = false
    @State private var userDefinedDays: Int = 1
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var hasChanges: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showItinerarySheet: Bool = false
    
    // Add these properties to store original values
    private let originalName: String
    private let originalDescription: String
    private let originalStartDate: Date?
    private let originalEndDate: Date?
    
    var onDelete: (() -> Void)?
    
    // Initialize with just the trip
    init(trip: Trip, navigationPath: Binding<NavigationPath>, onDelete: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: EditTripViewModel(trip: trip))
        _navigationPath = navigationPath
        self.onDelete = onDelete
        // Store original values
        self.originalName = trip.name
        self.originalDescription = trip.description
        self.originalStartDate = trip.startDate
        self.originalEndDate = trip.endDate
    }
    
    var dateRangeToHighlight: ClosedRange<Date>? {
        guard let start = startDate, let end = endDate else { return nil }
        return start <= end ? start...end : end...start
    }

    private func hasUnsavedChanges() -> Bool {
        if viewModel.trip.name != originalName { return true }
        if viewModel.trip.description != originalDescription { return true }
        if startDate != originalStartDate { return true }
        if endDate != originalEndDate { return true }
        return false
    }

    private func handleDelete() {
        Task {
            await viewModel.deleteTrip()
            presentationMode.wrappedValue.dismiss()
            onDelete?()
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "pencil")
                                .font(themeManager.selectedTheme.bodyTextFont)
                            Text("Trip Name")
                                .font(themeManager.selectedTheme.boldBodyTextFont)
                            Text("*")
                                .font(themeManager.selectedTheme.boldBodyTextFont)
                                .foregroundColor(themeManager.selectedTheme.warningColor)
                        }
                        .padding(.horizontal)
                        TextField("Enter name", text: $viewModel.trip.name)
                            .textFieldStyle(UnderlinedTextFieldStyle())
                            .padding(.horizontal, 6)
                    }
                    .padding(.top, 16)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "square.and.pencil")
                                .font(themeManager.selectedTheme.bodyTextFont)
                            Text("Description")
                                .font(themeManager.selectedTheme.boldBodyTextFont)
                        }
                        .padding(.horizontal)
                        TextEditor(text: $viewModel.trip.description)
                            .boxedTextEditorStyle(text: $viewModel.trip.description, placeholder: "Enter trip description")
                            .frame(height: 150)
                            .padding(.horizontal)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(themeManager.selectedTheme.bodyTextFont)
                            Text("Dates")
                                .font(themeManager.selectedTheme.boldBodyTextFont)
                        }
                        .padding(.bottom, 5)

                        HStack {
                            Text("\(startDate?.formatted(date: .long, time: .omitted) ?? " ")")
                                .font(themeManager.selectedTheme.bodyTextFont)
                                
                            Spacer()

                            if endDate != nil {
                                Image(systemName: "arrow.right")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                            } else {
                                Spacer()
                            }

                            Spacer()

                            Text("\(endDate?.formatted(date: .long, time: .omitted) ?? " ")")
                                .font(themeManager.selectedTheme.bodyTextFont)
                        }
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(height: 30)
                        )
                        .padding(.bottom, 10)

                        CalendarView(
                            selectedStartDate: Binding(
                                get: { viewModel.startDate },
                                set: { viewModel.updateStartDate($0) }
                            ),
                            selectedEndDate: Binding(
                                get: { viewModel.endDate },
                                set: { viewModel.updateEndDate($0) }
                            ),
                            highlightedRange: viewModel.dateRangeToHighlight
                        )
                    }
                    .padding(.horizontal)

                }
                .padding(.bottom, 150)
            }

            VStack(spacing: 8) {
                if viewModel.showToast {
                    Toast(message: viewModel.toastMessage, isPresented: $viewModel.showToast)
                }
                
                Button(action: {
                    if viewModel.validateForm() {
                        Task {
                            do {
                                try await viewModel.updateTrip()
                                presentationMode.wrappedValue.dismiss()
                            } catch {
                                print("Failed to update trip: \(error)")
                            }
                        }
                    }
                }) {
                    Text("Save Changes")
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 16)
                .shadow(radius: 5, y: 5)
            }
        }
        .navigationTitle("Edit Trip")
        .interactiveDismissDisabled()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if viewModel.hasChanges() {
                        showCancelAlert = true
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(themeManager.selectedTheme.accentColor)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(themeManager.selectedTheme.warningColor)
                    }
                }
            }
        }
        .alert("Discard Changes?", isPresented: $showCancelAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Discard", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to discard your changes?")
        }
        .alert("Delete Trip", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                handleDelete()
            }
        } message: {
            Text("Are you sure you want to delete this trip? This action cannot be undone.")
        }
        .onAppear {
            // Set initial dates
            startDate = viewModel.trip.startDate
            endDate = viewModel.trip.endDate
            // Add interceptor for the back button
            UINavigationBar.appearance().tintColor = UIColor(themeManager.selectedTheme.accentColor)
        }
        .onChange(of: viewModel.trip.name) { _, _ in
            hasChanges = hasUnsavedChanges()
        }
        .onChange(of: viewModel.trip.description) { _, _ in
            hasChanges = hasUnsavedChanges()
        }
        .onChange(of: startDate) { oldValue, newValue in
            hasChanges = hasUnsavedChanges()
            if let date = newValue {
                // Standardize to start of day in user's timezone
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)
                viewModel.trip.startDate = startOfDay
            }
        }
        .onChange(of: endDate) { oldValue, newValue in
            hasChanges = hasUnsavedChanges()
            if let date = newValue {
                // Standardize to end of day in user's timezone
                let calendar = Calendar.current
                if let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date) {
                    viewModel.trip.endDate = endOfDay
                }
            }
        }
        .accentColor(themeManager.selectedTheme.accentColor)
    }
}