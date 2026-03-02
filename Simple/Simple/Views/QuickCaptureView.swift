import SwiftUI
import SwiftData

struct QuickCaptureView: View {
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isTextFieldFocused: Bool
    @State private var title = ""
    @State private var section: TodoSection = .inbox
    @State private var selectedCategory: Category?
    @Query(sort: \Category.createdAt) private var categories: [Category]
    var onDismiss: @MainActor () -> Void

    var body: some View {
        VStack(spacing: 12) {
            TextField("Nova tarefa...", text: $title)
                .textFieldStyle(.plain)
                .font(.system(size: 20, weight: .medium))
                .focused($isTextFieldFocused)
                .onSubmit { save() }

            HStack(spacing: 8) {
                ForEach(Array(TodoSection.visible.enumerated()), id: \.element) { index, s in
                    SectionPill(
                        section: s,
                        isSelected: section == s,
                        shortcut: "\(index + 1)"
                    ) {
                        section = s
                    }
                }

                if !categories.isEmpty {
                    Divider()
                        .frame(height: 20)

                    Menu {
                        Button {
                            selectedCategory = nil
                        } label: {
                            Label("Nenhuma", systemImage: "xmark")
                        }
                        ForEach(categories) { cat in
                            Button {
                                selectedCategory = cat
                            } label: {
                                Label(cat.name, systemImage: cat.icon)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: selectedCategory?.icon ?? "folder")
                                .font(.system(size: 11))
                            Text(selectedCategory?.name ?? "Categoria")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(selectedCategory != nil
                                      ? AnyShapeStyle(Color(hex: selectedCategory!.colorHex).opacity(0.2))
                                      : AnyShapeStyle(.fill.quaternary))
                        }
                        .foregroundStyle(selectedCategory != nil
                                         ? Color(hex: selectedCategory!.colorHex)
                                         : .secondary)
                    }
                    .menuStyle(.borderlessButton)
                    .fixedSize()
                }

                Spacer()

                Text("⏎ salvar  ⎋ fechar")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary.opacity(0.5))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(width: 420)
        .onExitCommand { onDismiss() }
        .task {
            try? await Task.sleep(for: .milliseconds(100))
            isTextFieldFocused = true
        }
        .onCommandNumberPress { number in
            switch number {
            case 1: section = .inbox
            case 2: section = .hoje
            case 3: section = .depois
            default: break
            }
        }
    }

    private func save() {
        let text = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            onDismiss()
            return
        }
        let item = TodoItem(title: text, section: section)
        item.category = selectedCategory
        modelContext.insert(item)
        try? modelContext.save()
        title = ""
        onDismiss()
    }
}

// MARK: - Section Pill

private struct SectionPill: View {
    let section: TodoSection
    let isSelected: Bool
    let shortcut: String
    let action: () -> Void

    private var accentColor: Color {
        switch section {
        case .inbox: .blue
        case .hoje: .orange
        case .depois: .purple
        case .done: .gray
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: section.icon)
                    .font(.system(size: 11))
                Text(section.rawValue)
                    .font(.system(size: 12, weight: .medium))
                Text("⌘\(shortcut)")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? .white.opacity(0.6) : .secondary.opacity(0.4))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(accentColor) : AnyShapeStyle(.fill.quaternary))
            }
            .foregroundStyle(isSelected ? .white : .secondary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Key Hint

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

// MARK: - Command+Number Key Monitor

private struct CommandNumberKeyModifier: ViewModifier {
    let action: (Int) -> Void
    @State private var monitor: Any?

    func body(content: Content) -> some View {
        content
            .onAppear {
                monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    guard event.modifierFlags.contains(.command),
                          let characters = event.charactersIgnoringModifiers,
                          let number = Int(characters),
                          (1...9).contains(number) else {
                        return event
                    }
                    action(number)
                    return nil
                }
            }
            .onDisappear {
                if let monitor { NSEvent.removeMonitor(monitor) }
                monitor = nil
            }
    }
}

extension View {
    func onCommandNumberPress(action: @escaping (Int) -> Void) -> some View {
        modifier(CommandNumberKeyModifier(action: action))
    }
}
