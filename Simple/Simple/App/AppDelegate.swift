import AppKit
import SwiftUI
import SwiftData
import KeyboardShortcuts

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: FloatingPanel<AnyView>?
    var modelContainer: ModelContainer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        KeyboardShortcuts.reset(.quickCapture)

        KeyboardShortcuts.onKeyUp(for: .quickCapture) { @MainActor [weak self] in
            self?.showQuickCapture()
        }
    }

    private func showQuickCapture() {
        // Close existing panel if visible
        panel?.close()
        panel = nil

        guard let container = modelContainer else { return }

        let view = AnyView(
            QuickCaptureView { [weak self] in
                self?.panel?.close()
                self?.panel = nil
            }
            .modelContainer(container)
        )

        let p = FloatingPanel { view }

        // Center horizontally, upper third of screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let size = p.frame.size
            let x = screenFrame.midX - size.width / 2
            let y = screenFrame.midY + screenFrame.height * 0.15
            p.setFrameOrigin(NSPoint(x: x, y: y))
        }

        p.makeKeyAndOrderFront(nil)
        NSApp.activate()

        self.panel = p
    }
}
