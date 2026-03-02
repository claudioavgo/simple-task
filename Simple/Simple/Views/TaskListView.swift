import SwiftUI
import SwiftData

// MARK: - Task Filter

enum TaskFilter {
    case section(TodoSection)
    case category(PersistentIdentifier)
}

// MARK: - Task List View

/// Detail view showing a filtered list of tasks with inline add field.
struct TaskListView: View {
    let filter: TaskFilter

    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [TodoItem]
    @Query(sort: \Category.createdAt) private var categories: [Category]
    @State private var newTaskTitle = ""
    @FocusState private var isAddFieldFocused: Bool

    // MARK: - Filtered Data

    private var pending: [TodoItem] {
        filteredItems(done: false)
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var done: [TodoItem] {
        filteredItems(done: true)
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }

    private func filteredItems(done isDone: Bool) -> [TodoItem] {
        switch filter {
        case .section(let section):
            return allItems.filter { $0.effectiveSection == (isDone ? .done : section) && $0.isDone == isDone && (isDone ? $0.section == section : true) }
        case .category(let id):
            return allItems.filter { $0.category?.persistentModelID == id && $0.isDone == isDone }
        }
    }

    private var headerTitle: String {
        switch filter {
        case .section(let s): s.rawValue
        case .category(let id): categories.first { $0.persistentModelID == id }?.name ?? "Category"
        }
    }

    private var headerIcon: String {
        switch filter {
        case .section(let s): s.icon
        case .category(let id): categories.first { $0.persistentModelID == id }?.icon ?? "folder"
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().padding(.horizontal, 16)
            taskList
            Divider().padding(.horizontal, 16)
            inlineAddField
        }
    }

    // MARK: - Header

    private var header: some View {
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
    }

    // MARK: - Task List

    private var taskList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 2) {
                ForEach(pending) { item in
                    TaskRowView(item: item, showCategoryBadge: shouldShowBadge)
                        .padding(.horizontal, 16)
                }

                if !done.isEmpty {
                    completedDivider
                    ForEach(done) { item in
                        TaskRowView(item: item, showCategoryBadge: shouldShowBadge)
                            .opacity(0.5)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var completedDivider: some View {
        HStack {
            Rectangle().fill(.separator).frame(height: 0.5)
            Text("Completed")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Rectangle().fill(.separator).frame(height: 0.5)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    // MARK: - Inline Add

    private var inlineAddField: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus.circle")
                .foregroundStyle(.secondary)
                .font(.system(size: 16))
            TextField("New task...", text: $newTaskTitle)
                .textFieldStyle(.plain)
                .focused($isAddFieldFocused)
                .onSubmit(addTask)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var shouldShowBadge: Bool {
        if case .category = filter { return false }
        return true
    }

    // MARK: - Add Task

    private func addTask() {
        let text = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let item: TodoItem
        switch filter {
        case .section(let section):
            item = TodoItem(title: text, section: section)
            if section == .today {
                item.whenDate = Calendar.current.startOfDay(for: .now)
            }
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
