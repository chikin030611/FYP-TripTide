import SwiftUI

struct DayButton: View {
    let dayIndex: Int
    let isSelected: Bool
    let onSelect: () -> Void
    @StateObject private var themeManager = ThemeManager()

    var body: some View {
        Button(action: {
            onSelect()
        }) {
            VStack {
                Text("Day")
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundColor(
                        isSelected
                            ? themeManager.selectedTheme.bgTextColor
                            : themeManager.selectedTheme.secondaryColor)
                Text("\(dayIndex + 1)")
                    .font(themeManager.selectedTheme.titleFont)
                    .foregroundColor(
                        isSelected
                            ? themeManager.selectedTheme.bgTextColor
                            : themeManager.selectedTheme.secondaryColor)

            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        isSelected
                            ? themeManager.selectedTheme.accentColor
                            : themeManager.selectedTheme.backgroundColor)
            )
            .foregroundColor(
                isSelected ? .white : themeManager.selectedTheme.primaryColor
            )
        }
    }
}

struct CompactDayButton: View {
    let dayIndex: Int
    let isSelected: Bool
    let onSelect: () -> Void
    @StateObject private var themeManager = ThemeManager()

    var body: some View {
        Button(action: {
            onSelect()
        }) {
            VStack {
                Text("Day")
                    .font(themeManager.selectedTheme.captionTextFont)
                    .foregroundColor(
                        isSelected
                            ? themeManager.selectedTheme.bgTextColor
                            : themeManager.selectedTheme.secondaryColor)
                            
                Text("\(dayIndex + 1)")
                    .font(themeManager.selectedTheme.boldBodyTextFont)
                    .foregroundColor(
                        isSelected
                            ? themeManager.selectedTheme.bgTextColor
                            : themeManager.selectedTheme.secondaryColor)

            }
            .padding(.vertical, 10)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        isSelected
                            ? themeManager.selectedTheme.accentColor
                            : themeManager.selectedTheme.backgroundColor)
            )
            .foregroundColor(
                isSelected ? .white : themeManager.selectedTheme.primaryColor
            )
        }
    }
}