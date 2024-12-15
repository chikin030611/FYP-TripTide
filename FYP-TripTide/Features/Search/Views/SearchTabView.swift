import SwiftUI

struct SearchTabView: View {
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let attraction = getAttraction(by: "1") {
                        NavigationLink {
                            AttractionDetailView(attraction: attraction)
                        } label: {
                            SearchResultRow(attraction: attraction)
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Search")
        }
    }
}
