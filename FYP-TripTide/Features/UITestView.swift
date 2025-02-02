//
//  StyleDisplayer.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 3/11/2024.
//

import SwiftUI

struct UITestView: View {
    @StateObject private var filterViewModel = FilterViewModel()
    @StateObject private var themeManager = ThemeManager()
    @State private var isFilterSheetPresented = false
    let filterOptions = ["Amusement Park", "Beach"]
    @State private var filterOptionsCount = 5
    
    var body: some View {
        HStack {
            Button {
                isFilterSheetPresented = true
            } label: {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Filter")
                        .font(themeManager.selectedTheme.bodyTextFont)
                }
            }
            .buttonStyle(RectangularButtonStyle())

            if filterOptionsCount > 0 {
                Button {
                    isFilterSheetPresented = true
                } label: {
                    Text("\(filterOptionsCount) filters is selected")
                }
                .buttonStyle(SecondaryTagButtonStyle())
            }

            Spacer()
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            FilterSheet(viewModel: filterViewModel)
        }
        .padding(.horizontal)
    }
}

#Preview {
    UITestView()
}
