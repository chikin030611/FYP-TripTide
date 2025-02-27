import SwiftUI

struct CalendarView: View {
    @Binding var selectedStartDate: Date?
    @Binding var selectedEndDate: Date?
    var highlightedRange: ClosedRange<Date>?
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    @State private var selectedMonth = Date()
    @State private var refreshID = UUID()

    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        VStack {
            // Month selector
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                .foregroundColor(themeManager.selectedTheme.accentColor)
                
                Text(monthYearString(from: selectedMonth))
                    .font(.title2)
                    .padding(.horizontal)
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(themeManager.selectedTheme.accentColor)
            }
            .padding()
            
            // Days of week header
            LazyVGrid(columns: columns) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: columns) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: isDateSelected(date),
                            isHighlighted: isDateHighlighted(date),
                            onTap: { handleDateSelection(date) }
                        )
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
            }
            .id(refreshID)
        }
        .onChange(of: highlightedRange) { _, _ in
            refreshID = UUID()
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: selectedMonth)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func handleDateSelection(_ date: Date) {
        if selectedStartDate == nil {
            // First selection
            selectedStartDate = date
        } else if selectedEndDate == nil {
            // Second selection
            if let start = selectedStartDate {
                if date < start {
                    // If selected date is earlier than start date, swap them
                    selectedEndDate = start
                    selectedStartDate = date
                } else {
                    selectedEndDate = date
                }
            }
        } else {
            // Reset selection
            selectedStartDate = date
            selectedEndDate = nil
        }
    }
    
    private func isDateSelected(_ date: Date) -> Bool {
        date == selectedStartDate || date == selectedEndDate
    }
    
    private func isDateHighlighted(_ date: Date) -> Bool {
        guard let range = highlightedRange else { return false }
        return range.contains(date)
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func previousMonth() {
        selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
    }
    
    private func nextMonth() {
        selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isHighlighted: Bool
    let onTap: () -> Void
    let themeManager = ThemeManager()
    
    var body: some View {
        Text("\(Calendar.current.component(.day, from: date))")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .background(
                Circle()
                    .fill(isHighlighted ? themeManager.selectedTheme.accentColor.opacity(0.25) : Color.clear)
            )
            .overlay(
                Circle()
                    .stroke(isSelected ? themeManager.selectedTheme.accentColor : Color.clear, lineWidth: 2)
            )
            .onTapGesture(perform: onTap)
    }
}