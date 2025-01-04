import SwiftUI

struct OpenHoursSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var themeManager = ThemeManager()
    
    let openHours: [OpenHour]
    private let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    private var todayWeekdayIndex: Int {
        let today = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: today)
        return (weekday + 5) % 7 + 1
    }
    
    private var sortedWeekdayIndices: [Int] {
        let today = todayWeekdayIndex
        return (0..<7).map { (today - 1 + $0) % 7 + 1 }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedWeekdayIndices, id: \.self) { weekdayIndex in
                    if let openHour = openHours.first(where: { $0.weekdayIndex == weekdayIndex }) {
                        HStack {
                            Text(weekdays[weekdayIndex - 1])
                                .font(themeManager.selectedTheme.boldBodyTextFont)
                            
                            if weekdayIndex == todayWeekdayIndex {
                                Text("(Today)")
                                    .font(themeManager.selectedTheme.captionTextFont)
                                    .foregroundStyle(themeManager.selectedTheme.accentColor)
                            }
                            
                            Spacer()
                            
                            if let openTime = openHour.openTime, let closeTime = openHour.closeTime {
                                if openHour.isOpen24Hours {
                                    Text("Open 24 Hours")
                                        .font(themeManager.selectedTheme.bodyTextFont)
                                } else {
                                    Text("\(openTime) - \(closeTime)")
                                        .font(themeManager.selectedTheme.bodyTextFont)
                                }
                            } else {
                                Text("Closed")
                                    .font(themeManager.selectedTheme.bodyTextFont)
                                    .foregroundStyle(themeManager.selectedTheme.warningColor)
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