import SwiftUI

struct OpenHoursSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var themeManager = ThemeManager()
    
    let openHours: [OpenHour]
    private let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<7) { index in
                    if let openHour = openHours.first(where: { $0.weekdayIndex == index + 1 }) {
                        HStack {
                            Text(weekdays[index])
                                .font(themeManager.selectedTheme.boldBodyTextFont)
                            
                            Spacer()
                            
                            if let openTime = openHour.openTime, let closeTime = openHour.closeTime {
                                Text("\(openTime) - \(closeTime)")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                            } else {
                                Text("Closed")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                            }
                        }
                        .foregroundStyle(themeManager.selectedTheme.primaryColor)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Opening Hours")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.height(380)])
    }
} 