import SwiftUI
import SwiftData

struct MenuBarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @State private var newTaskTitle = ""
    @Query private var allItems: [TodoItem]

    private var todayCount: Int {
        allItems.filter { $0.section == .hoje && !$0.isDone }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            // Open main window
            Button {
                openWindow(id: "main")
                NSApp.activate()
            } label: {
                HStack {
                    Label("Abrir Simple", systemImage: "macwindow")
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

            // Inline add field
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.system(size: 16))

                TextField("Nova tarefa no Inbox...", text: $newTaskTitle)
                    .textFieldStyle(.plain)
                    .onSubmit { addTask() }
            }
            .padding(12)

            Divider()

            // Summary
            HStack {
                if todayCount > 0 {
                    Text("\(todayCount) tarefa\(todayCount == 1 ? "" : "s") hoje")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Nenhuma tarefa para hoje")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // Footer
            HStack {
                Button("Sair") {
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
