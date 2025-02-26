import SwiftUI

struct CreateTripView: View {
    @StateObject private var viewModel = CreateTripViewModel()
    @StateObject private var themeManager = ThemeManager()
    @State private var userDefinedDays: Int = 1
    @State private var startDate: Date?
    @State private var endDate: Date?
    
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
                            .padding(.bottom, startDate != nil ? 0 : 5)
                            HStack {
                                Text("\(startDate?.formatted(date: .long, time: .omitted) ?? "")")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    
                                Spacer()

                                if endDate != nil {
                                    Image(systemName: "arrow.right")
                                        .font(themeManager.selectedTheme.bodyTextFont)
                                } else {
                                    Spacer()
                                }

                                Spacer()

                                Text("\(endDate?.formatted(date: .long, time: .omitted) ?? "")")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                            }
                            
                            CalendarView(
                                selectedStartDate: $startDate,
                                selectedEndDate: $endDate,
                                highlightedRange: dateRangeToHighlight
                            )
                        }
                        .padding(.horizontal)

                    }
                    .padding(.bottom, 100)
                }

                Button(action: {
                    viewModel.createTrip()
                }) {
                    Text("Create Trip")
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 16)
                .shadow(radius: 5, y: 5)
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
        }
    }
}