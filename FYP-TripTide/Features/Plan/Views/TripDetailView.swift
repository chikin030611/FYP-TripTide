import SwiftUI

struct TripDetailView: View {
    @ObservedObject var viewModel: TripDetailViewModel
    @StateObject private var themeManager = ThemeManager()
    @State private var isDescriptionExpanded = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack {
                    ZStack {
                        Image(viewModel.trip.image)
                            .resizable()
                            .frame(height: 400)
                            .clipped()
                            .edgesIgnoringSafeArea(.all)
                            .cornerRadius(20)

                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.01), Color.black.opacity(0.6),
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .cornerRadius(20)

                        VStack(alignment: .leading, spacing: 3) {
                            VStack(alignment: .leading, spacing: 12) {

                                Text(viewModel.trip.name)
                                    .font(themeManager.selectedTheme.largerTitleFont)
                                    .foregroundColor(.white)

                                HStack(alignment: .top) {
                                    Image(systemName: "calendar")
                                        .frame(width: 20, height: 20)
                                    Text(
                                        "\(viewModel.trip.startDate.formatted(date: .long, time: .omitted)) - \(viewModel.trip.endDate.formatted(date: .long, time: .omitted))"
                                    )
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                }
                                .padding(.horizontal, 8)
                                .background(
                                    Rectangle()
                                        .cornerRadius(10)
                                        .foregroundColor(themeManager.selectedTheme.accentColor)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .frame(height: 25)
                                )
                            }
                            .padding(.top, 100)
                        }
                        .padding(.top, 175)
                        .padding(.horizontal, 15)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        // Description
                        Text("Description")
                            .font(themeManager.selectedTheme.titleFont)
                            .foregroundColor(themeManager.selectedTheme.primaryColor)

                        Divider()
                            .background(themeManager.selectedTheme.primaryColor)
                            .frame(height: 1)

                        ZStack {
                            Text(viewModel.trip.description)
                                .font(themeManager.selectedTheme.bodyTextFont)
                                .foregroundColor(themeManager.selectedTheme.primaryColor)
                                .lineLimit(isDescriptionExpanded ? nil : 3)

                        }
                        if viewModel.trip.description.count > 150 {
                            Button(action: {
                                isDescriptionExpanded.toggle()
                            }) {
                                Text(isDescriptionExpanded ? "Show Less" : "Show More")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    .foregroundColor(themeManager.selectedTheme.accentColor)
                                    .padding(.top, 4)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 10) {

                        HStack(alignment: .center) {
                            Text("Places")
                                .font(themeManager.selectedTheme.titleFont)
                                .foregroundColor(themeManager.selectedTheme.primaryColor)

                            Spacer()

                            HStack(alignment: .center) {
                                Image(systemName: "heart.fill")
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(themeManager.selectedTheme.bgTextColor)
                                Text("\(viewModel.trip.savedCount) Saves")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    .foregroundColor(themeManager.selectedTheme.bgTextColor)
                            }
                            .padding(.horizontal, 8)
                            .background(
                                Rectangle()
                                    .cornerRadius(10)
                                    .foregroundColor(themeManager.selectedTheme.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 25)
                            )
                            .frame(alignment: .topLeading)
                        }

                        Divider()
                            .background(themeManager.selectedTheme.primaryColor)
                            .frame(height: 1)

                        if viewModel.isLoading {
                            ProgressView("Loading places...")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else if let error = viewModel.error {
                            Text("Error: \(error)")
                                .foregroundColor(themeManager.selectedTheme.warningColor)
                                .padding()
                        } else {
                            // Places sections
                            DisclosureGroup(
                                content: {
                                    if viewModel.touristAttractionsCards.isEmpty {
                                        Text("No tourist attractions saved")
                                            .foregroundColor(themeManager.selectedTheme.secondaryColor)
                                            .padding()
                                    } else {
                                        CardGroup(cards: viewModel.touristAttractionsCards, style: .wide)
                                    }
                                },
                                label: {
                                    Text("Tourist Attractions (\(viewModel.touristAttractionsCards.count))")
                                        .font(themeManager.selectedTheme.titleFont)
                                        .foregroundColor(themeManager.selectedTheme.primaryColor)
                                }
                            )

                            DisclosureGroup(
                                content: {
                                    if viewModel.restaurantsCards.isEmpty {
                                        Text("No restaurants saved")
                                            .foregroundColor(themeManager.selectedTheme.secondaryColor)
                                            .padding()
                                    } else {
                                        CardGroup(cards: viewModel.restaurantsCards, style: .wide)
                                    }
                                },
                                label: {
                                    Text("Restaurants (\(viewModel.restaurantsCards.count))")
                                        .font(themeManager.selectedTheme.titleFont)
                                        .foregroundColor(themeManager.selectedTheme.primaryColor)
                                }
                            )

                            DisclosureGroup(
                                content: {
                                    if viewModel.lodgingsCards.isEmpty {
                                        Text("No lodgings saved")
                                            .foregroundColor(themeManager.selectedTheme.secondaryColor)
                                            .padding()
                                    } else {
                                        CardGroup(cards: viewModel.lodgingsCards, style: .wide)
                                    }
                                },
                                label: {
                                    Text("Lodgings (\(viewModel.lodgingsCards.count))")
                                        .font(themeManager.selectedTheme.titleFont)
                                        .foregroundColor(themeManager.selectedTheme.primaryColor)
                                }
                            )
                        }
                    }
                    .padding()

                }
                .padding(.bottom, 100)
            }
            .ignoresSafeArea(edges: .top)

            // Bottom Bar
            VStack {
                HStack {
                    NavigationLink(destination: EditTripView(trip: viewModel.trip)) {
                        Text("Edit")
                            .font(themeManager.selectedTheme.bodyTextFont)
                            .foregroundColor(themeManager.selectedTheme.accentColor)
                    }
                    .buttonStyle(EditButtonStyle())

                    Spacer()

                    Button(action: {
                        print("Plan your itinerary")
                    }) {
                        Text("Plan your itinerary")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(themeManager.selectedTheme.appBackgroundColor)
            .frame(maxWidth: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.trip.printTrip()
                    }) {
                        Text("Print Trip")
                    }
                }
            }
        }
        .task {
            await viewModel.fetchPlaces()
        }
    }
}


