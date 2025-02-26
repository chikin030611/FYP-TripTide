import SwiftUI

struct PlanTabView: View {
    @StateObject private var viewModel = PlanTabViewModel()
    @StateObject private var themeManager = ThemeManager()

    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.trips.isEmpty {
                    Text("No trips found")
                } else {
                    VStack(spacing: 16) {
                        ForEach(viewModel.trips) { trip in
                            NavigationLink(destination: TripDetailView(viewModel: TripDetailViewModel(trip: trip))) {
                                TripCard(trip: trip)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Plan")
    }
}
