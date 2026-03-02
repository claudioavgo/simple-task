import SwiftUI
import SwiftData

// MARK: - Sidebar Item

enum SidebarItem: Hashable {
    case section(TodoSection)
    case category(PersistentIdentifier)
}

// MARK: - Sidebar View

/// Left sidebar with built-in lists and user categories.
struct SidebarView: View {
    @Binding var selection: SidebarItem?
    @Binding var showNewCategory: Bool

    @Query(sort: \Category.createdAt) private var categories: [Category]
    @Query private var allItems: [TodoItem]

    var body: some View {
        List(selection: $selection) {
            Section("Lists") {
                ForEach(TodoSection.visible, id: \.self) { section in
                    sidebarRow(
                        title: section.rawValue,
                        icon: section.icon,
                        color: SectionStyle.color(for: section),
                        count: count(for: section),
                        tag: .section(section)
                    )
                }
            }

            Section("Categories") {
                ForEach(categories) { category in
                    sidebarRow(
                        title: category.name,
                        icon: category.icon,
                        color: Color(hex: category.colorHex),
                        count: count(for: category),
                        tag: .category(category.persistentModelID)
                    )
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteCategory(category)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }

                Button {
                    showNewCategory = true
                } label: {
                    Label("New Category", systemImage: "plus")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.leading, 4)
            }
        }
        .listStyle(.sidebar)
    }

    // MARK: - Row Builder

    private func sidebarRow(title: String, icon: String, color: Color, count: Int, tag: SidebarItem) -> some View {
        Label {
            HStack {
                Text(title)
                Spacer()
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.fill.quaternary, in: Capsule())
                }
            }
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 14))
        }
        .tag(tag)
    }

    // MARK: - Counts

    private func count(for section: TodoSection) -> Int {
        allItems.filter { $0.effectiveSection == section && !$0.isDone }.count
    }

    private func count(for category: Category) -> Int {
        category.tasks.filter { !$0.isDone }.count
    }

    // MARK: - Delete

    @MainActor
    private func deleteCategory(_ category: Category) {
        if case .category(let id) = selection, id == category.persistentModelID {
            selection = .section(.inbox)
        }
        let context = category.modelContext
        context?.delete(category)
        try? context?.save()
    }
}
