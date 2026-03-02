import Foundation

enum TodoSection: String, Codable, CaseIterable, Identifiable {
    case inbox = "Inbox"
    case hoje = "Hoje"
    case depois = "Depois"
    case done = "Done"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .inbox: "tray"
        case .hoje: "sun.max"
        case .depois: "moon"
        case .done: "checkmark.circle"
        }
    }

    /// Sections visible in the main UI (excludes done)
    static var visible: [TodoSection] {
        [.inbox, .hoje, .depois]
    }
}
