import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Bindable var item: TodoItem
    var showCategoryBadge: Bool = true
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.createdAt) private var categories: [Category]

    var body: some View {
        HStack(spacing: 8) {
            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    item.toggleDone()
                    try? modelContext.save()
                }
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isDone ? .green : .secondary)
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)

            Text(item.title)
                .strikethrough(item.isDone)
                .foregroundStyle(item.isDone ? .secondary : .primary)
                .lineLimit(1)

            if showCategoryBadge, let cat = item.category {
                HStack(spacing: 3) {
                    Image(systemName: cat.icon)
                        .font(.system(size: 9))
                    Text(cat.name)
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(Color(hex: cat.colorHex))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(hex: cat.colorHex).opacity(0.12), in: Capsule())
            }

            Spacer()
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
        .contextMenu {
            if item.isDone {
                Button {
                    item.toggleDone()
                    try? modelContext.save()
                } label: {
                    Label("Marcar como pendente", systemImage: "arrow.uturn.backward")
                }
            }

            // Move between sections
            ForEach(TodoSection.visible, id: \.self) { section in
                if item.section != section {
                    Button {
                        item.section = section
                        item.isDone = false
                        item.completedAt = nil
                        try? modelContext.save()
                    } label: {
                        Label("Mover para \(section.rawValue)", systemImage: section.icon)
                    }
                }
            }

            Divider()

            // Category submenu
            Menu("Categoria") {
                Button {
                    item.category = nil
                    try? modelContext.save()
                } label: {
                    Label("Nenhuma", systemImage: "xmark")
                }

                ForEach(categories) { cat in
                    Button {
                        item.category = cat
                        try? modelContext.save()
                    } label: {
                        Label(cat.name, systemImage: cat.icon)
                    }
                }
            }

            Divider()

            Button(role: .destructive) {
                modelContext.delete(item)
                try? modelContext.save()
            } label: {
                Label("Apagar", systemImage: "trash")
            }
        }
    }
}
