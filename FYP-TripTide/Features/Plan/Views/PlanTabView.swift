import SwiftUI

struct PlanTabView: View {
    @StateObject private var viewModel = PlanTabViewModel()
    @StateObject private var themeManager = ThemeManager()
    @State private var showingCreateTrip = false
    @State private var showingCancelAlert = false
    @State private var interstitialSheetPresentation = false
    @State private var navigationPath = NavigationPath()
    @State private var hasAppeared = false
    @State private var shouldRefresh = false
    @State private var isRefreshing = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                if !viewModel.isAuthenticated {
                    UnauthenticatedView()
                } else {
                    ScrollView {
                        if viewModel.trips.isEmpty && !viewModel.isLoading {
                            // Empty state view
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
                                if viewModel.isLoading && viewModel.trips.isEmpty {
                                    ProgressView("Loading trips...")
                                        .padding()
                                }
                                
                                ForEach(viewModel.trips) { trip in
                                    NavigationLink(destination: TripDetailView(viewModel: TripDetailViewModel(trip: trip), navigationPath: $navigationPath)) {
                                        TripCard(trip: trip, navigationPath: $navigationPath)
                                    }
                                    .padding(.bottom, 15)
                                }
                            }
                            .padding(.bottom, 80)
                            .padding(.horizontal, 32)
                        }
                    }
                    .padding(.top, 16)
                    .overlay {
                        if viewModel.isLoading && !viewModel.trips.isEmpty {
                            ProgressView()
                        }
                    }
                }

                if viewModel.isAuthenticated {
                    Button(action: {
                        showingCreateTrip = true
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
                CreateTripView(isPresented: $showingCreateTrip, showCancelAlert: $showingCancelAlert)
                    .interactiveDismissDisabled(true)
                    .environmentObject(viewModel)
            }
            .onChange(of: showingCreateTrip) { oldValue, newValue in
                if newValue {
                    interstitialSheetPresentation = true
                }
            }
            .onAppear {
                if !hasAppeared {
                    // Check authentication state and fetch trips if authenticated
                    if viewModel.isAuthenticated {
                        viewModel.fetchTrips()
                    }
                    hasAppeared = true
                }
            }
            .onChange(of: navigationPath) { oldValue, newValue in
                if newValue.count == 0 {
                    // We've returned to root, refresh the trips
                    print("🔄 Returned to root, refreshing trips")
                    viewModel.fetchTrips()
                }
            }
            .onChange(of: shouldRefresh) { oldValue, newValue in
                if newValue && !isRefreshing {
                    isRefreshing = true
                    print("🔄 Refreshing trips due to shouldRefresh trigger")
                    viewModel.fetchTrips()
                    
                    // Reset refresh flags after a delay
                    Task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                        shouldRefresh = false
                        isRefreshing = false
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .tripDeleted)) { _ in
            print("📣 Received tripDeleted notification")
            shouldRefresh = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .placeRemovedFromTrip)) { _ in
            print("📣 Received placeRemovedFromTrip notification")
            shouldRefresh = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .placeAddedToTrip)) { _ in
            print("📣 Received placeAddedToTrip notification")
            shouldRefresh = true
        }
    }
}

private struct UnauthenticatedView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var tabManager: TabManager
    
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
                tabManager.switchToTab(5)
            }) {
                Text("Get Started")
                    .padding()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }
}
