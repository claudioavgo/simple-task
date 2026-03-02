import SwiftUI
import SwiftData

struct SidebarView: View {
    @Binding var selection: SidebarItem?
    @Binding var showNewCategory: Bool
    @Query(sort: \Category.createdAt) private var categories: [Category]
    @Query private var allItems: [TodoItem]

    private func count(for section: TodoSection) -> Int {
        allItems.filter { $0.section == section && !$0.isDone }.count
    }

    private func count(for category: Category) -> Int {
        category.tasks.filter { !$0.isDone }.count
    }

    var body: some View {
        List(selection: $selection) {
            Section("Listas") {
                ForEach(TodoSection.visible, id: \.self) { section in
                    sidebarRow(
                        title: section.rawValue,
                        icon: section.icon,
                        color: colorForSection(section),
                        count: count(for: section),
                        tag: SidebarItem.section(section)
                    )
                }
            }

            Section("Categorias") {
                ForEach(categories) { category in
                    sidebarRow(
                        title: category.name,
                        icon: category.icon,
                        color: Color(hex: category.colorHex),
                        count: count(for: category),
                        tag: SidebarItem.category(category.persistentModelID)
                    )
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteCategory(category)
                        } label: {
                            Label("Apagar", systemImage: "trash")
                        }
                    }
                }

                Button {
                    showNewCategory = true
                } label: {
                    Label("Nova Categoria", systemImage: "plus")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.leading, 4)
            }
        }
        .listStyle(.sidebar)
    }

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

    private func colorForSection(_ section: TodoSection) -> Color {
        switch section {
        case .inbox: .blue
        case .hoje: .orange
        case .depois: .purple
        case .done: .gray
        }
    }

    @MainActor
    private func deleteCategory(_ category: Category) {
        if let sel = selection, case .category(let id) = sel, id == category.persistentModelID {
            selection = .section(.inbox)
        }
        let context = category.modelContext
        context?.delete(category)
        try? context?.save()
    }
}

// MARK: - Color hex extension

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
