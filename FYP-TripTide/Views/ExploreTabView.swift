//
//  ExploreTabView.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 31/10/2024.
//

import SwiftUI

struct ExploreTabView: View {
    @StateObject var themeManager = ThemeManager()
    @StateObject private var viewModel = ExploreTabViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    TitleSection(themeManager: themeManager, logoIcon: viewModel.logoIcon)
                    
                    Divider()
                    
                    // For You
                    BodySection(themeManager: themeManager,
                              imageName: viewModel.forYouSection.icon,
                              title: viewModel.forYouSection.title,
                              description: viewModel.forYouSection.description,
                              cards: viewModel.forYouCards)
                        .padding(.vertical, 5)
                    
                    // Restaurant
                    BodySection(themeManager: themeManager,
                              imageName: viewModel.restaurantSection.icon,
                              title: viewModel.restaurantSection.title,
                              description: viewModel.restaurantSection.description,
                              cards: viewModel.restaurantCards)
                        .padding(.vertical, 5)
                    
                    // Accommodation
                    BodySection(themeManager: themeManager,
                              imageName: viewModel.accommodationSection.icon,
                              title: viewModel.accommodationSection.title,
                              description: viewModel.accommodationSection.description,
                              cards: viewModel.accommodationCards)
                        .padding(.vertical, 5)
                }
                .padding()
            }
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Title Section
struct TitleSection: View {
    @StateObject var themeManager: ThemeManager
    let logoIcon: String
    
    var body: some View {
        HStack {
            Image(systemName: logoIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            
            Text("TripTide")
                .font(themeManager.selectedTheme.largerTitleFont)
        }
        .foregroundStyle(themeManager.selectedTheme.accentColor)
    }
}

// MARK: - Body Section
struct BodySection: View {
    @StateObject var themeManager: ThemeManager
    
    var imageName: String
    var title: String
    var description: String
    var cards: [Card]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(themeManager.selectedTheme.accentColor)
                
                Text(title)
                    .font(themeManager.selectedTheme.boldTitleFont)
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
            }
            
            Text(description)
                .font(themeManager.selectedTheme.bodyTextFont)
                .foregroundStyle(themeManager.selectedTheme.primaryColor)
            
            CardGroup(cards: cards)
            
        }
    }
}

#Preview {
    ExploreTabView()
}
