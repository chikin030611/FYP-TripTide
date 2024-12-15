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
                    // Highly Rated
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(themeManager.selectedTheme.accentColor)
                            Text(viewModel.highlyRatedSection.title)
                                .font(themeManager.selectedTheme.boldTitleFont)
                                .foregroundStyle(themeManager.selectedTheme.primaryColor)
                        }
                        
                        CardGroup(cards: viewModel.highlyRatedCards, style: .large)
            
                    }
                    
                    // Restaurant
                    BodySection(themeManager: themeManager,
                                title: viewModel.restaurantSection.title,
                                cards: viewModel.restaurantCards)
                        .padding(.vertical, 5)
                    
                    // Accommodation
                    BodySection(themeManager: themeManager,
                                title: viewModel.accommodationSection.title,
                                cards: viewModel.accommodationCards)
                        .padding(.vertical, 5)
                }
                .padding()
            }
        }
    }
}

// MARK: - Body Section
struct BodySection: View {
    @StateObject var themeManager: ThemeManager
    
    var title: String
    var cards: [Card]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(themeManager.selectedTheme.boldTitleFont)
                .foregroundStyle(themeManager.selectedTheme.primaryColor)
            
            CardGroup(cards: cards, style: .regular)
            
        }
    }
}

#Preview {
    ExploreTabView()
}
