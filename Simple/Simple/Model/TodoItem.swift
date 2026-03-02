import Foundation
import SwiftData

@Model
final class TodoItem {
    var title: String
    var sectionRaw: String
    var isDone: Bool
    var createdAt: Date
    var completedAt: Date?
    var category: Category?

    var section: TodoSection {
        get { TodoSection(rawValue: sectionRaw) ?? .inbox }
        set { sectionRaw = newValue.rawValue }
    }

    init(title: String, section: TodoSection = .inbox) {
        self.title = title
        self.sectionRaw = section.rawValue
        self.isDone = false
        self.createdAt = Date()
    }

    func toggleDone() {
        isDone.toggle()
        completedAt = isDone ? Date() : nil
    }
}
