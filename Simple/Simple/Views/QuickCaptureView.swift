import SwiftUI
import SwiftData

// MARK: - Quick Capture View

/// Spotlight-style floating panel for rapid task entry (⌥Space).
/// Layout: text field on top, toolbar with section pills + date shortcuts below.
struct QuickCaptureView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.createdAt) private var categories: [Category]

    @FocusState private var isFocused: Bool
    @State private var title = ""
    @State private var section: TodoSection = .inbox
    @State private var selectedCategory: Category?
    @State private var whenDate: Date?
    @State private var deadline: Date?

    var onDismiss: @MainActor () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Text input ──
            TextField("New task...", text: $title)
                .textFieldStyle(.plain)
                .font(.system(size: 18, weight: .regular))
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 14)
                .focused($isFocused)
                .onSubmit(save)

            Divider()
                .padding(.horizontal, 16)

            // ── Toolbar ──
            HStack(alignment: .center, spacing: 6) {
                sectionPills
                toolbarDivider

                whenDateButton
                deadlineButton

                if !categories.isEmpty {
                    toolbarDivider
                    categoryMenu
                }

                Spacer()

                Text("⏎ save  ⎋ close")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.secondary.opacity(0.35))
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(width: 520)
        .onExitCommand(perform: onDismiss)
        .task {
            try? await Task.sleep(for: .milliseconds(100))
            isFocused = true
        }
        .onCommandNumberPress { n in
            if n == 1 { section = .inbox }
            if n == 2 { section = .today }
            if n == 3 { section = .later }
        }
    }

    // MARK: - Section Pills

    private var sectionPills: some View {
        ForEach(Array(TodoSection.visible.enumerated()), id: \.element) { idx, s in
            ToolbarPill(
                icon: s.icon,
                label: s.rawValue,
                accessory: "⌘\(idx + 1)",
                isActive: section == s,
                tint: SectionStyle.color(for: s)
            ) {
                withAnimation(.easeInOut(duration: 0.15)) { section = s }
            }
        }
    }

    // MARK: - When Date

    private var whenDateButton: some View {
        Menu {
            Button { setWhenDate(.now) } label: {
                Label("Today", systemImage: "sun.max")
            }
            Button { setWhenDate(daysFromNow: 1) } label: {
                Label("Tomorrow", systemImage: "arrow.right")
            }
            Button { setWhenDate(nextWeekday: 2) } label: {
                Label("Next Monday", systemImage: "calendar")
            }
            if whenDate != nil {
                Divider()
                Button(role: .destructive) { whenDate = nil } label: {
                    Label("Remove date", systemImage: "xmark")
                }
            }
        } label: {
            ToolbarPillContent(
                icon: "calendar",
                label: whenDate.map { DateFormatting.relativeLabel(for: $0) },
                isActive: whenDate != nil,
                tint: .blue
            )
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }

    // MARK: - Deadline

    private var deadlineButton: some View {
        Menu {
            Button { setDeadline(.now) } label: {
                Label("Today", systemImage: "sun.max")
            }
            Button { setDeadline(daysFromNow: 1) } label: {
                Label("Tomorrow", systemImage: "arrow.right")
            }
            Button { setDeadline(nextWeekday: 6) } label: {
                Label("Next Friday", systemImage: "calendar")
            }
            if deadline != nil {
                Divider()
                Button(role: .destructive) { deadline = nil } label: {
                    Label("Remove deadline", systemImage: "xmark")
                }
            }
        } label: {
            ToolbarPillContent(
                icon: "flag",
                label: deadline.map { DateFormatting.relativeLabel(for: $0) },
                isActive: deadline != nil,
                tint: .red
            )
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }

    // MARK: - Category Menu

    private var categoryMenu: some View {
        Menu {
            Button {
                selectedCategory = nil
            } label: {
                Label("None", systemImage: "xmark")
            }
            Divider()
            ForEach(categories) { cat in
                Button { selectedCategory = cat } label: {
                    Label(cat.name, systemImage: cat.icon)
                }
            }
        } label: {
            ToolbarPillContent(
                icon: selectedCategory?.icon ?? "tag",
                label: selectedCategory?.name,
                isActive: selectedCategory != nil,
                tint: selectedCategory.map { Color(hex: $0.colorHex) } ?? .secondary
            )
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }

    // MARK: - Toolbar Divider

    private var toolbarDivider: some View {
        Rectangle()
            .fill(.quaternary)
            .frame(width: 1, height: 16)
    }

    // MARK: - Date Helpers

    private func setWhenDate(_ date: Date) {
        let cal = Calendar.current
        whenDate = cal.startOfDay(for: date)
        if cal.isDateInToday(date) { section = .today }
    }

    private func setWhenDate(daysFromNow days: Int) {
        let cal = Calendar.current
        whenDate = cal.date(byAdding: .day, value: days, to: cal.startOfDay(for: .now))
    }

    private func setWhenDate(nextWeekday weekday: Int) {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.weekday = weekday
        if let next = cal.nextDate(after: .now, matching: comps, matchingPolicy: .nextTime) {
            whenDate = cal.startOfDay(for: next)
        }
    }

    private func setDeadline(_ date: Date) {
        deadline = Calendar.current.startOfDay(for: date)
    }

    private func setDeadline(daysFromNow days: Int) {
        let cal = Calendar.current
        deadline = cal.date(byAdding: .day, value: days, to: cal.startOfDay(for: .now))
    }

    private func setDeadline(nextWeekday weekday: Int) {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.weekday = weekday
        if let next = cal.nextDate(after: .now, matching: comps, matchingPolicy: .nextTime) {
            deadline = cal.startOfDay(for: next)
        }
    }

    // MARK: - Save

    private func save() {
        let text = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return onDismiss() }

        let item = TodoItem(title: text, section: section)
        item.category = selectedCategory
        item.whenDate = whenDate
        item.deadline = deadline
        modelContext.insert(item)
        try? modelContext.save()

        title = ""
        onDismiss()
    }
}

// MARK: - Toolbar Pill (Button)

/// Tappable pill used for section selection in the quick capture toolbar.
private struct ToolbarPill: View {
    let icon: String
    let label: String
    var accessory: String? = nil
    let isActive: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ToolbarPillContent(icon: icon, label: label, accessory: accessory, isActive: isActive, tint: tint)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Toolbar Pill Content (Reusable)

/// Visual content shared between pill buttons and menu labels.
/// Uses a fixed height to ensure all pills align regardless of content.
private struct ToolbarPillContent: View {
    let icon: String
    var label: String? = nil
    var accessory: String? = nil
    let isActive: Bool
    let tint: Color

    private let pillHeight: CGFloat = 24

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .medium))
                .frame(width: 12, alignment: .center)

            if let label, !label.isEmpty {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .fixedSize()
            }

            if let accessory {
                Text(accessory)
                    .font(.system(size: 10, weight: .medium).monospaced())
                    .baselineOffset(0)
                    .foregroundStyle(isActive ? .white.opacity(0.5) : .secondary.opacity(0.3))
            }
        }
        .frame(height: pillHeight)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isActive ? AnyShapeStyle(tint) : AnyShapeStyle(.fill.quaternary))
        )
        .foregroundStyle(isActive ? .white : .secondary)
    }
}

// MARK: - Key Hint (exported for other views)

struct KeyHint: View {
    let key: String
    let label: String

    init(_ key: String, label: String) {
        self.key = key
        self.label = label
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(key)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
            Text(label)
                .font(.system(size: 10))
        }
        .foregroundStyle(.secondary.opacity(0.6))
    }
}
