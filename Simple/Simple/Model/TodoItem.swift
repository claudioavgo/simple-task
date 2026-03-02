import Foundation
import SwiftData

@Model
final class TodoItem {

    // MARK: - Stored Properties

    var title: String
    var sectionRaw: String
    var isDone: Bool
    var createdAt: Date
    var completedAt: Date?
    var category: Category?

    /// The day this task should surface in Today (Things 3 "When" date).
    /// When this date arrives, `effectiveSection` returns `.today`.
    var whenDate: Date?

    /// Hard due date. Shown as a countdown badge on the task row.
    var deadline: Date?

    // MARK: - Computed Properties

    var section: TodoSection {
        get { TodoSection(rawValue: sectionRaw) ?? .inbox }
        set { sectionRaw = newValue.rawValue }
    }

    /// Resolves the display section by auto-promoting scheduled tasks.
    /// If `whenDate` ≤ today → task appears in Today regardless of `sectionRaw`.
    var effectiveSection: TodoSection {
        if isDone { return .done }
        if let when = whenDate {
            let cal = Calendar.current
            if cal.isDateInToday(when) || when < cal.startOfDay(for: .now) {
                return .today
            }
        }
        return section
    }

    /// Signed day count until deadline. Negative means overdue.
    var daysUntilDeadline: Int? {
        guard let deadline else { return nil }
        let cal = Calendar.current
        return cal.dateComponents([.day], from: cal.startOfDay(for: .now), to: cal.startOfDay(for: deadline)).day
    }

    // MARK: - Init

    init(title: String, section: TodoSection = .inbox) {
        self.title = title
        self.sectionRaw = section.rawValue
        self.isDone = false
        self.createdAt = .now
    }

    // MARK: - Actions

    func toggleDone() {
        isDone.toggle()
        completedAt = isDone ? .now : nil
    }
}
