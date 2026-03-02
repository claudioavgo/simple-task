import SwiftUI
import SwiftData

struct SectionView: View {
    let section: TodoSection
    @Query private var items: [TodoItem]

    init(section: TodoSection) {
        self.section = section
        let sectionRaw = section.rawValue
        _items = Query(
            filter: #Predicate<TodoItem> {
                $0.sectionRaw == sectionRaw
            },
            sort: [SortDescriptor(\TodoItem.createdAt, order: .reverse)]
        )
    }

    private var pending: [TodoItem] { items.filter { !$0.isDone } }
    private var done: [TodoItem] { items.filter { $0.isDone } }

    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(pending) { item in
                    TaskRowView(item: item)
                }
                if !done.isEmpty {
                    ForEach(done) { item in
                        TaskRowView(item: item)
                            .opacity(0.6)
                    }
                }
            } header: {
                Label(section.rawValue, systemImage: section.icon)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
