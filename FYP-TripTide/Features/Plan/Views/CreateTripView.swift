import SwiftUI

struct CreateTripView: View {
    @StateObject private var viewModel = CreateTripViewModel()
    @EnvironmentObject private var planTabViewModel: PlanTabViewModel
    @StateObject private var themeManager = ThemeManager()
    @Binding var isPresented: Bool
    @Binding var showCancelAlert: Bool
    @Environment(\.dismiss) private var dismiss
    
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
                                Text("*")
                                    .font(themeManager.selectedTheme.boldBodyTextFont)
                                    .foregroundColor(themeManager.selectedTheme.warningColor)
                            }
                            .padding(.bottom, 5)

                            HStack {
                                Text("\(viewModel.startDate?.formatted(date: .long, time: .omitted) ?? " ")")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    
                                Spacer()

                                if viewModel.endDate != nil {
                                    Image(systemName: "arrow.right")
                                        .font(themeManager.selectedTheme.bodyTextFont)
                                } else {
                                    Spacer()
                                }

                                Spacer()

                                Text("\(viewModel.endDate?.formatted(date: .long, time: .omitted) ?? " ")")
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
                                await viewModel.createTrip()
                                if viewModel.tripCreated {
                                    planTabViewModel.fetchTrips()
                                    isPresented = false
                                    dismiss()
                                }
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
            .accentColor(themeManager.selectedTheme.accentColor)
        }
    }
    
    private func showCancelConfirmation() {
        if viewModel.hasChanges() {
            showCancelAlert = true
        } else {
            isPresented = false
            dismiss()
        }
    }
}