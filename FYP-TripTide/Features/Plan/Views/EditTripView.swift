import SwiftUI

struct EditTripView: View {
    @StateObject private var viewModel: EditTripViewModel
    @StateObject private var themeManager = ThemeManager()
    @Environment(\.dismiss) private var dismiss
    @State private var showCancelAlert: Bool = false
    @State private var showToast: Bool = false
    @State private var userDefinedDays: Int = 1
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var hasChanges: Bool = false
    
    // Add these properties to store original values
    private let originalName: String
    private let originalDescription: String
    private let originalStartDate: Date?
    private let originalEndDate: Date?
    
    // Initialize with just the trip
    init(trip: Trip) {
        _viewModel = StateObject(wrappedValue: EditTripViewModel(trip: trip))
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

    // Add this function to check for actual changes
    private func hasUnsavedChanges() -> Bool {
        if viewModel.trip.name != originalName { return true }
        if viewModel.trip.description != originalDescription { return true }
        if startDate != originalStartDate { return true }
        if endDate != originalEndDate { return true }
        return false
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
                            selectedStartDate: $startDate,
                            selectedEndDate: $endDate,
                            highlightedRange: dateRangeToHighlight
                        )
                    }
                    .padding(.horizontal)

                }
                .padding(.bottom, 150)
            }

            VStack(spacing: 8) {
                if showToast {
                    Toast(message: "Please enter a name for your trip.", isPresented: $showToast)
                }
                
                Button(action: {
                    if !viewModel.trip.name.isEmpty {
                        viewModel.updateTrip()
                        dismiss()
                    } else {
                        withAnimation {
                            showToast = true
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
                    if hasUnsavedChanges() {
                        showCancelAlert = true
                    } else {
                        dismiss()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(themeManager.selectedTheme.accentColor)
                }
            }
        }
        .alert("Discard Changes?", isPresented: $showCancelAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Discard", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Are you sure you want to discard your changes?")
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