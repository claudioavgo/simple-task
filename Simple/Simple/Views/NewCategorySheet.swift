import SwiftUI
import SwiftData

struct NewCategorySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedIcon = "folder"
    @State private var selectedColor = "#007AFF"

    private let icons = [
        "folder", "house", "briefcase", "book",
        "graduationcap", "heart", "star", "cart",
        "airplane", "car", "figure.walk", "music.note",
        "gamecontroller", "camera", "paintbrush", "wrench"
    ]

    private let colors = [
        "#007AFF", "#FF3B30", "#FF9500", "#FFCC00",
        "#34C759", "#5856D6", "#AF52DE", "#FF2D55",
        "#00C7BE", "#8E8E93"
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("Nova Categoria")
                .font(.headline)

            TextField("Nome", text: $name)
                .textFieldStyle(.roundedBorder)

            // Icon picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Ícone")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(36)), count: 8), spacing: 8) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                        } label: {
                            Image(systemName: icon)
                                .font(.system(size: 16))
                                .frame(width: 32, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(selectedIcon == icon ? Color(hex: selectedColor).opacity(0.2) : .clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(selectedIcon == icon ? Color(hex: selectedColor) : .clear, lineWidth: 1.5)
                                )
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(selectedIcon == icon ? Color(hex: selectedColor) : .secondary)
                    }
                }
            }

            // Color picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Cor")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    ForEach(colors, id: \.self) { hex in
                        Button {
                            selectedColor = hex
                        } label: {
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 24, height: 24)
                                .overlay {
                                    if selectedColor == hex {
                                        Circle()
                                            .stroke(.white, lineWidth: 2)
                                            .frame(width: 18, height: 18)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Preview
            HStack(spacing: 6) {
                Image(systemName: selectedIcon)
                    .foregroundStyle(Color(hex: selectedColor))
                Text(name.isEmpty ? "Preview" : name)
                    .foregroundStyle(name.isEmpty ? .secondary : .primary)
            }
            .font(.system(size: 14))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            // Actions
            HStack {
                Button("Cancelar") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Criar") {
                    createCategory()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 360)
    }

    private func createCategory() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let category = Category(name: trimmed, icon: selectedIcon, colorHex: selectedColor)
        modelContext.insert(category)
        try? modelContext.save()
        dismiss()
    }
}
