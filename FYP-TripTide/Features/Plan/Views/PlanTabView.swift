import SwiftUI

struct PlanTabView: View {
    @StateObject private var viewModel = PlanTabViewModel()
    @StateObject private var themeManager = ThemeManager()

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    if viewModel.trips.isEmpty {
                        Text("No trips found")
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

                NavigationLink(destination: CreateTripView()) {
                    Text("Create a new trip")
                        .padding()
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: .infinity)
                .padding(.bottom, 16)
                .shadow(radius: 5, y: 5)
            }
            .navigationTitle("Plan")
        }
    }
}
