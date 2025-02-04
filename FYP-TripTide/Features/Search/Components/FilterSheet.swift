import SwiftUI

struct FilterSheet: View {
    @ObservedObject var viewModel: FilterViewModel
    @StateObject var themeManager: ThemeManager = ThemeManager()
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0
    @State var filterOptions: [String] = []
    
    var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text("Filter")
                    .font(themeManager.selectedTheme.largeTitleFont)
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .padding(.top, 10)

                ScrollView(.horizontal, showsIndicators: false) {
                    if !viewModel.selectedTags.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(Array(viewModel.selectedTags), id: \.self) { tag in
                                Button {
                                    viewModel.toggleTag(tag)
                                } label: {
                                    Text(tag.name)
                                        .font(themeManager.selectedTheme.bodyTextFont)
                                }
                                .buttonStyle(RemoveTagButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        Color.clear
                            .frame(height: 33)
                    }
                }
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
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 400)

                Divider()
                    .padding(.vertical, 10)

                VStack(alignment: .center) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Apply")
                            .font(themeManager.selectedTheme.bodyTextFont)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)

                Spacer()
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
