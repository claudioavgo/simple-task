import SwiftUI
import SwiftData

enum TaskFilter {
    case section(TodoSection)
    case category(PersistentIdentifier)
}

struct TaskListView: View {
    let filter: TaskFilter
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [TodoItem]
    @Query(sort: \Category.createdAt) private var categories: [Category]
    @State private var newTaskTitle = ""
    @FocusState private var isAddFieldFocused: Bool

    private var filteredItems: [TodoItem] {
        switch filter {
        case .section(let section):
            return allItems.filter { $0.section == section }
        case .category(let id):
            return allItems.filter { $0.category?.persistentModelID == id }
        }
    }

    private var pending: [TodoItem] {
        filteredItems
            .filter { !$0.isDone }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var done: [TodoItem] {
        filteredItems
            .filter { $0.isDone }
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }

    private var headerTitle: String {
        switch filter {
        case .section(let section): section.rawValue
        case .category(let id):
            categories.first { $0.persistentModelID == id }?.name ?? "Categoria"
        }
    }

    private var headerIcon: String {
        switch filter {
        case .section(let section): section.icon
        case .category(let id):
            categories.first { $0.persistentModelID == id }?.icon ?? "folder"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: headerIcon)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text(headerTitle)
                    .font(.title.bold())
                Text("\(pending.count)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 16)

            // Task list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(pending) { item in
                        TaskRowView(item: item, showCategoryBadge: shouldShowBadge)
                            .padding(.horizontal, 16)
                    }

                    if !done.isEmpty {
                        HStack {
                            Rectangle()
                                .fill(.separator)
                                .frame(height: 0.5)
                            Text("Concluídas")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            Rectangle()
                                .fill(.separator)
                                .frame(height: 0.5)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)

                        ForEach(done) { item in
                            TaskRowView(item: item, showCategoryBadge: shouldShowBadge)
                                .opacity(0.5)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            Divider()
                .padding(.horizontal, 16)

            // Inline add
            HStack(spacing: 8) {
                Image(systemName: "plus.circle")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 16))
                TextField("Nova tarefa...", text: $newTaskTitle)
                    .textFieldStyle(.plain)
                    .focused($isAddFieldFocused)
                    .onSubmit { addTask() }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private var shouldShowBadge: Bool {
        if case .category = filter { return false }
        return true
    }

    private func addTask() {
        let text = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let item: TodoItem
        switch filter {
        case .section(let section):
            item = TodoItem(title: text, section: section)
        case .category(let id):
            item = TodoItem(title: text, section: .inbox)
            if let cat = categories.first(where: { $0.persistentModelID == id }) {
                item.category = cat
            }
        }

        modelContext.insert(item)
        try? modelContext.save()
        newTaskTitle = ""
    }
}
