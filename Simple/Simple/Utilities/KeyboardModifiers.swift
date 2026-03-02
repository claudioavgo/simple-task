import SwiftUI
import AppKit

// MARK: - Command+Number Key Monitor

/// Listens for ⌘1–⌘9 key events via NSEvent local monitor.
private struct CommandNumberKeyModifier: ViewModifier {
    let action: (Int) -> Void
    @State private var monitor: Any?

    func body(content: Content) -> some View {
        content
            .onAppear {
                monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    guard event.modifierFlags.contains(.command),
                          let chars = event.charactersIgnoringModifiers,
                          let number = Int(chars),
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
    /// Calls `action` with the digit when the user presses ⌘1–⌘9.
    func onCommandNumberPress(action: @escaping (Int) -> Void) -> some View {
        modifier(CommandNumberKeyModifier(action: action))
    }
}
