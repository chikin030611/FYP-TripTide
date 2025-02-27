import SwiftUI

struct CreateTripView: View {
    @StateObject private var viewModel = CreateTripViewModel()
    @StateObject private var themeManager = ThemeManager()
    @Binding var isPresented: Bool
    @Binding var showCancelAlert: Bool
    @State private var userDefinedDays: Int = 1
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var showToast: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var dateRangeToHighlight: ClosedRange<Date>? {
        guard let start = startDate, let end = endDate else { return nil }
        return start <= end ? start...end : end...start
    }

    var body: some View {
        NavigationView {
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
                            viewModel.createTrip()
                            isPresented = false
                            dismiss()
                        } else {
                            withAnimation {
                                showToast = true
                            }
                        }
                    }) {
                        Text("Create Trip")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    .shadow(radius: 5, y: 5)
                }
            }
            .navigationTitle("Create Trip")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showCancelConfirmation()
                }
            )
            .alert("Cancel Trip Creation", isPresented: $showCancelAlert) {
                Button("Continue Editing", role: .cancel) { }
                Button("Discard Changes", role: .destructive) {
                    isPresented = false
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to cancel? Your changes will be lost.")
            }
            .onChange(of: startDate) { oldValue, newValue in
                if let date = newValue {
                    // Standardize to start of day in user's timezone
                    let calendar = Calendar.current
                    let startOfDay = calendar.startOfDay(for: date)
                    viewModel.trip.startDate = startOfDay
                }
            }
            .onChange(of: endDate) { oldValue, newValue in
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
    
    private func showCancelConfirmation() {
        // Only show alert if there are changes
        if !viewModel.trip.name.isEmpty || 
           !viewModel.trip.description.isEmpty || 
           startDate != nil || 
           endDate != nil {
            showCancelAlert = true
        } else {
            // If no changes, just dismiss
            isPresented = false
            dismiss()
        }
    }
}