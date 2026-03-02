import Foundation
import SwiftData

@Model
final class Category {
    @Attribute(.unique) var name: String
    var icon: String
    var colorHex: String
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \TodoItem.category)
    var tasks: [TodoItem] = []

    init(name: String, icon: String = "folder", colorHex: String = "#007AFF") {
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.createdAt = Date()
    }
}
