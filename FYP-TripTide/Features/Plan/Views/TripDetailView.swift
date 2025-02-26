import SwiftUI

struct TripDetailView: View {
    @ObservedObject var viewModel: TripDetailViewModel
    
    var body: some View {
        Text(viewModel.trip.name)
    }
}