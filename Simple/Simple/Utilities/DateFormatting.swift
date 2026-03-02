import SwiftUI

// MARK: - Date Helpers

/// Shared date helpers used across quick capture, task rows, and popovers.
enum DateFormatting {

    /// Short human-readable label for a date relative to today.
    static func relativeLabel(for date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date)     { return "Today" }
        if cal.isDateInTomorrow(date)  { return "Tomorrow" }
        if cal.isDateInYesterday(date) { return "Yesterday" }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    /// Deadline countdown text.
    static func deadlineText(daysLeft days: Int) -> String {
        if days < 0  { return "Overdue" }
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        return "\(days)d"
    }

    /// Deadline tint color based on urgency.
    static func deadlineColor(daysLeft days: Int) -> Color {
        if days < 0  { return .red }
        if days <= 1 { return .orange }
        if days <= 3 { return .yellow }
        return .secondary
    }
}

// MARK: - Section Colors

/// Consistent color mapping for built-in sections.
enum SectionStyle {
    static func color(for section: TodoSection) -> Color {
        switch section {
        case .inbox: .blue
        case .today: .orange
        case .later: .purple
        case .done:  .gray
        }
    }
}

// MARK: - Color+Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
