//
//  ExploreTabView.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 31/10/2024.
//

import SwiftUI

struct ExploreTabView: View {
    
    @StateObject var themeManager = ThemeManager()
    
    // MARK: - Constants
    let logoIcon = "airplane.departure"
    
    // For You Section
    let forYouIcon = "sparkles"
    let forYouTitle = NSLocalizedString("For You", comment: "Title of the For You section")
    let forYouDescription = NSLocalizedString("Discover places that are perfect for you", comment: "Description of the For You section")
    
    // TODO: Replace with actual data
    @State var forYouCards: [Card] = [
        Card(placeId: "1"),
        Card(placeId: "2"),
        Card(placeId: "3")
    ]
    
    // Restaurant Section
    let restaurantIcon = "fork.knife"
    let restaurantTitle = NSLocalizedString("Restaurant", comment: "Title of the restaurant section")
    let restaurantDescription = NSLocalizedString("Locals' favourite dining places", comment: "Description of the restaurant section")
    
    // TODO: Replace with actual data
    @State var restaurantCards: [Card] = [
        Card(placeId: "4"),
        Card(placeId: "5"),
        Card(placeId: "6"),
        Card(placeId: "7")
    ]
    
    // Accommodation Section
    let accommodationIcon = "bed.double.fill"
    let accommodationTitle = NSLocalizedString("Accommodation", comment: "Title of the accommodation section")
    let accommodationDescription = NSLocalizedString("Cozy places to stay", comment: "Description of the accommodation section")
    
    // TODO: Replace with actual data
    @State var accommodationCards: [Card] = [
        Card(placeId: "8"),
        Card(placeId: "9"),
        Card(placeId: "10")
    ]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    // Title
                    TitleSection(themeManager: themeManager)
                    
                    Divider()
                    
                    // For You
                    BodySection(themeManager: themeManager,
                                imageName: forYouIcon,
                                title: forYouTitle,
                                description: forYouDescription,
                                cards: forYouCards
                    )
                        .padding(.vertical, 5)
                    
                    // Restaurant
                    BodySection(themeManager: themeManager,
                                imageName: restaurantIcon,
                                title: restaurantTitle,
                                description: restaurantDescription,
                                cards: restaurantCards
                    )
                        .padding(.vertical, 5)
                    
                    // Accommodation
                    BodySection(themeManager: themeManager,
                                imageName: accommodationIcon,
                                title: accommodationTitle,
                                description: accommodationDescription,
                                cards: accommodationCards
                    )
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
    
    var body: some View {
        HStack {
            Image(systemName: "airplane.departure")
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
