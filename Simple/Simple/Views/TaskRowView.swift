import SwiftUI
import SwiftData

/// A single task row with checkbox, title, badges, and context menu.
struct TaskRowView: View {
    @Bindable var item: TodoItem
    var showCategoryBadge: Bool = true

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.createdAt) private var categories: [Category]

    var body: some View {
        HStack(spacing: 8) {
            checkboxButton

            Text(item.title)
                .strikethrough(item.isDone)
                .foregroundStyle(item.isDone ? .secondary : .primary)
                .lineLimit(1)

            categoryBadge

            Spacer()

            whenDateBadge
            deadlineBadge
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
        .contextMenu { contextMenuContent }
    }

    // MARK: - Checkbox

    private var checkboxButton: some View {
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
    }

    // MARK: - Category Badge

    @ViewBuilder
    private var categoryBadge: some View {
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
    }

    // MARK: - When Date Badge

    @ViewBuilder
    private var whenDateBadge: some View {
        if !item.isDone, let when = item.whenDate, !Calendar.current.isDateInToday(when) {
            Text(DateFormatting.relativeLabel(for: when))
                .font(.system(size: 10))
                .foregroundStyle(.blue)
        }
    }

    // MARK: - Deadline Badge

    @ViewBuilder
    private var deadlineBadge: some View {
        if !item.isDone, let days = item.daysUntilDeadline {
            HStack(spacing: 2) {
                Image(systemName: "flag.fill")
                    .font(.system(size: 8))
                Text(DateFormatting.deadlineText(daysLeft: days))
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(DateFormatting.deadlineColor(daysLeft: days))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(DateFormatting.deadlineColor(daysLeft: days).opacity(0.1), in: Capsule())
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private var contextMenuContent: some View {
        if item.isDone {
            Button {
                item.toggleDone()
                try? modelContext.save()
            } label: {
                Label("Mark as pending", systemImage: "arrow.uturn.backward")
            }
        }

        // Move between sections
        ForEach(TodoSection.visible, id: \.self) { section in
            if item.section != section {
                Button {
                    item.section = section
                    if section == .today {
                        item.whenDate = Calendar.current.startOfDay(for: .now)
                    }
                    item.isDone = false
                    item.completedAt = nil
                    try? modelContext.save()
                } label: {
                    Label("Move to \(section.rawValue)", systemImage: section.icon)
                }
            }
        }

        Divider()

        scheduleMenu
        categoryMenu

        Divider()

        Button(role: .destructive) {
            modelContext.delete(item)
            try? modelContext.save()
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    // MARK: - Schedule Submenu

    private var scheduleMenu: some View {
        Menu("Schedule") {
            Button {
                item.whenDate = Calendar.current.startOfDay(for: .now)
                item.section = .today
                try? modelContext.save()
            } label: {
                Label("Today", systemImage: "sun.max")
            }
            Button {
                let cal = Calendar.current
                item.whenDate = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: .now))
                try? modelContext.save()
            } label: {
                Label("Tomorrow", systemImage: "arrow.right")
            }
            Button {
                let cal = Calendar.current
                var comps = DateComponents()
                comps.weekday = 2
                if let next = cal.nextDate(after: .now, matching: comps, matchingPolicy: .nextTime) {
                    item.whenDate = cal.startOfDay(for: next)
                }
                try? modelContext.save()
            } label: {
                Label("Next Monday", systemImage: "calendar")
            }
            if item.whenDate != nil {
                Divider()
                Button {
                    item.whenDate = nil
                    try? modelContext.save()
                } label: {
                    Label("Remove date", systemImage: "xmark")
                }
            }
        }
    }

    // MARK: - Category Submenu

    private var categoryMenu: some View {
        Menu("Category") {
            Button {
                item.category = nil
                try? modelContext.save()
            } label: {
                Label("None", systemImage: "xmark")
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
    }
}
