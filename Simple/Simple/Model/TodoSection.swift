import Foundation

/// Built-in task sections inspired by Things 3's time-based lists.
enum TodoSection: String, Codable, CaseIterable, Identifiable {
    case inbox  = "Inbox"
    case today  = "Today"
    case later  = "Later"
    case done   = "Done"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .inbox: "tray"
        case .today: "sun.max"
        case .later: "moon"
        case .done:  "checkmark.circle"
        }
    }

    /// Sections visible in the sidebar and quick capture (excludes done).
    static var visible: [TodoSection] {
        [.inbox, .today, .later]
    }
}
