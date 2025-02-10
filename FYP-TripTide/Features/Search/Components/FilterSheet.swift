import SwiftUI

struct FilterSheet: View {
    @ObservedObject var viewModel: FilterViewModel
    @StateObject var themeManager: ThemeManager = ThemeManager()
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0
    @State var isForSearching = false
    @State var filterOptions: [String] = []
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Filter")
                    .font(themeManager.selectedTheme.largeTitleFont)
                    .padding(.horizontal)
                    .padding(.bottom, 15)

                Divider()
                    .padding(.bottom, 10)

                VStack(alignment: .leading) {
                    HStack {
                        Text("Selected Filters")
                            .font(themeManager.selectedTheme.bodyTextFont)
                            .foregroundColor(themeManager.selectedTheme.secondaryColor)

                        Spacer()

                        Button {
                            viewModel.selectedTags = []
                        } label: {
                            Text("Clear")
                        }
                        .buttonStyle(SecondaryTagButtonStyle())
                        
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        if !viewModel.selectedTags.isEmpty {
                            HStack(spacing: 8) {
                                ForEach(Array(viewModel.selectedTags), id: \.self) { tag in
                                    Button {
                                        viewModel.toggleTag(tag)
                                    } label: {
                                        Text(tag.name.formatTagName())
                                            .font(themeManager.selectedTheme.bodyTextFont)
                                    }
                                    .buttonStyle(RemoveTagButtonStyle())
                                }
                            }
                        } else {
                            Color.clear
                                .frame(height: 33)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                // Custom Tab Bar
                HStack(spacing: 0) {
                    TabButton(title: "Tourist Attractions", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    
                    TabButton(title: "Restaurants", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    
                    TabButton(title: "Lodging", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .padding(.horizontal)
                
                TabView(selection: $selectedTab) {
                    // Tourist Attractions Tab
                    ScrollView {
                        FlowLayout(spacing: 8) {
                            ForEach(viewModel.touristAttractionOptions, id: \.name) { option in
                                Button {
                                    viewModel.toggleTag(option)
                                } label: {
                                    Text(option.name.formatTagName())
                                        .font(themeManager.selectedTheme.bodyTextFont)
                                }
                                .buttonStyle(TagButtonStyle(isSelected: viewModel.selectedTags.contains(option)))
                            }
                        }
                        .padding()
                    }
                    .tag(0)
                    
                    // Restaurants Tab
                    ScrollView {
                        FlowLayout(spacing: 8) {
                            ForEach(viewModel.restaurantOptions, id: \.name) { option in
                                Button {
                                    viewModel.toggleTag(option)
                                } label: {
                                    Text(option.name.formatTagName())
                                        .font(themeManager.selectedTheme.bodyTextFont)
                                }
                                .buttonStyle(TagButtonStyle(isSelected: viewModel.selectedTags.contains(option)))
                            }
                        }
                        .padding()
                    }
                    .tag(1)
                    
                    // Lodging Tab
                    ScrollView {
                        FlowLayout(spacing: 8) {
                            ForEach(viewModel.lodgingOptions, id: \.name) { option in
                                Button {
                                    viewModel.toggleTag(option)
                                } label: {
                                    Text(option.name.formatTagName())
                                        .font(themeManager.selectedTheme.bodyTextFont)
                                }
                                .buttonStyle(TagButtonStyle(isSelected: viewModel.selectedTags.contains(option)))
                            }
                        }
                        .padding()
                    }
                    .tag(2)
                }
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 400)
        
                Divider()
                    .padding(.vertical, 10)

                VStack(alignment: .center) {
                    HStack {
                        
                        if isForSearching {
                            Spacer()

                            Button {
                                dismiss()
                            } label: {
                                Text("Apply")
                            }
                            .buttonStyle(SmallerPrimaryButtonStyle())

                            Spacer()

                            Button {
                                viewModel.applyAndSearchFilters()
                                dismiss()
                            } label: {
                                Text("Apply and Search")
                            }
                            .buttonStyle(SmallerPrimaryButtonStyle())

                            Spacer()
                        } else {
                            Button {
                                dismiss()
                            } label: {
                                Text("Apply")
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
}

// Custom Tab Button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .foregroundColor(isSelected ? themeManager.selectedTheme.primaryColor : .gray)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                Rectangle()
                    .fill(isSelected ? themeManager.selectedTheme.primaryColor : Color.clear)
                    .frame(height: 2)
            }
        }
    }
}
