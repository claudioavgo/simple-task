import SwiftUI
import SwiftData

/// Compact menu bar popover with quick add and summary.
struct MenuBarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Query private var allItems: [TodoItem]
    @State private var newTaskTitle = ""

    private var todayCount: Int {
        allItems.filter { $0.effectiveSection == .today && !$0.isDone }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            // Open main window
            Button {
                openWindow(id: "main")
                NSApp.activate()
            } label: {
                HStack {
                    Label("Open Simple", systemImage: "macwindow")
                    Spacer()
                    Text("⌘O")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .keyboardShortcut("o")

            Divider()

            // Inline add
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.system(size: 16))
                TextField("New task in Inbox...", text: $newTaskTitle)
                    .textFieldStyle(.plain)
                    .onSubmit(addTask)
            }
            .padding(12)

            Divider()

            // Summary
            HStack {
                Text(todayCount > 0
                     ? "\(todayCount) task\(todayCount == 1 ? "" : "s") today"
                     : "No tasks for today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // Quit
            HStack {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .font(.caption)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 280)
    }

    private func addTask() {
        let title = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        let item = TodoItem(title: title, section: .inbox)
        modelContext.insert(item)
        try? modelContext.save()
        newTaskTitle = ""
    }
}
