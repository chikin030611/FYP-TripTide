import SwiftUI

struct PlanTabView: View {
    @StateObject private var viewModel = PlanTabViewModel()
    @StateObject private var themeManager = ThemeManager()
    @State private var isShowingCreateTrip = false
    @State private var isShowingCancelAlert = false
    @State private var interstitialSheetPresentation = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    if viewModel.trips.isEmpty {
                        HStack {
                            Image(systemName: "airplane")
                                .font(.system(size: 36))
                                .foregroundColor(themeManager.selectedTheme.secondaryColor)
                            VStack(alignment: .leading) {
                                Text("No trips found.")
                                    .font(themeManager.selectedTheme.titleFont)
                                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
                                Text("Create a new trip to get started.")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    .foregroundColor(themeManager.selectedTheme.secondaryColor)
                            }
                        }
                        .padding(16)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(viewModel.trips) { trip in
                                NavigationLink(destination: TripDetailView(viewModel: TripDetailViewModel(trip: trip))) {
                                    TripCard(trip: trip)
                                }
                                .padding(.bottom, 15)
                            }
                        }
                        .padding(.bottom, 80) // Add padding at bottom for button
                        .padding(.horizontal, 32)
                    }
                }

                Button(action: {
                    isShowingCreateTrip = true
                }) {
                    Text("Create a new trip")
                        .padding()
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: .infinity)
                .padding(.bottom, 16)
                .shadow(radius: 5, y: 5)
            }
            .navigationTitle("Plan")
            .sheet(isPresented: $interstitialSheetPresentation) {
                CreateTripView(isPresented: $isShowingCreateTrip, showCancelAlert: $isShowingCancelAlert)
                    .interactiveDismissDisabled(true)
            }
            .onChange(of: isShowingCreateTrip) { oldValue, newValue in
                if newValue {
                    interstitialSheetPresentation = true
                }
            }
        }
    }
}
