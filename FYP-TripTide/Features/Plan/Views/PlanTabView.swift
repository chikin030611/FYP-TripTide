import SwiftUI

struct PlanTabView: View {
    @StateObject private var viewModel = PlanTabViewModel()
    @StateObject private var themeManager = ThemeManager()
    @State private var isShowingCreateTrip = false
    @State private var isShowingCancelAlert = false
    @State private var interstitialSheetPresentation = false
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                if !viewModel.isAuthenticated {
                    UnauthenticatedView()
                } else if viewModel.isLoading {
                    ProgressView("Loading trips...")
                } else if let error = viewModel.error {
                    VStack {
                        Text("Error: \(error)")
                        Button("Retry") {
                            viewModel.fetchTrips()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                } else {
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
                                    NavigationLink(destination: TripDetailView(viewModel: TripDetailViewModel(trip: trip), navigationPath: $navigationPath)) {
                                        TripCard(trip: trip, navigationPath: $navigationPath)
                                    }
                                    .padding(.bottom, 15)
                                }
                            }
                            .padding(.bottom, 80) // Add padding at bottom for button
                            .padding(.horizontal, 32)
                        }
                    }
                    .padding(.top, 16)
                }

                if viewModel.isAuthenticated {
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
            }
            .navigationTitle("Plan")
            .sheet(isPresented: $interstitialSheetPresentation, onDismiss: {
                if viewModel.trips.isEmpty {
                    viewModel.fetchTrips()
                }
            }) {
                CreateTripView(isPresented: $isShowingCreateTrip, showCancelAlert: $isShowingCancelAlert)
                    .interactiveDismissDisabled(true)
                    .environmentObject(viewModel)
            }
            .onChange(of: isShowingCreateTrip) { oldValue, newValue in
                if newValue {
                    interstitialSheetPresentation = true
                }
            }
            .onAppear {
                if viewModel.isAuthenticated {
                    viewModel.fetchTrips()
                }
            }
            .onChange(of: navigationPath) { oldValue, newValue in
                if newValue.count == 0 {
                    // We've returned to root, refresh the trips
                    print("🔄 Returned to root, refreshing trips")
                    viewModel.fetchTrips()
                }
            }
        }
    }
}

private struct UnauthenticatedView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var tabController: TabController
    
    var body: some View {
        VStack(spacing: 16) {
            Image("unauth_plan")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
            Text("Looks like you're not logged in :(")
                .font(themeManager.selectedTheme.titleFont)
                .foregroundColor(themeManager.selectedTheme.primaryColor)
            Text("Get started by creating an account.")
                .font(themeManager.selectedTheme.bodyTextFont)
                .foregroundColor(themeManager.selectedTheme.secondaryColor)

            Button(action: {
                tabController.switchToTab(5)
            }) {
                Text("Get Started")
                    .padding()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }
}
