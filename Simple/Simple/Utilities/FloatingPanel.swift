import AppKit
import SwiftUI

/// Floating panel for Spotlight-style UI.
///
/// Uses NSVisualEffectView as contentView to provide the blur background
/// and rounded corners. NSHostingView is added as a subview on top,
/// avoiding the opaque-background artifact that occurs when NSHostingView
/// is the direct contentView of a transparent window.
final class FloatingPanel<Content: View>: NSPanel {
    init(@ViewBuilder content: () -> Content) {
        super.init(
            contentRect: .zero,
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        // Window transparency
        isFloatingPanel = true
        level = .floating
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true

        // Hide titlebar visually (but keep .titled for .fullSizeContentView to work)
        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        // Behavior
        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        animationBehavior = .utilityWindow

        // Hide traffic light buttons
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true

        // 1. NSVisualEffectView as contentView — provides blur + rounded corners
        let visualEffect = NSVisualEffectView()
        visualEffect.material = .popover
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 12
        visualEffect.layer?.cornerCurve = .continuous
        visualEffect.layer?.masksToBounds = true

        // 2. NSHostingView as subview — SwiftUI content on top, no background needed
        let hostingView = NSHostingView(rootView: content().ignoresSafeArea())
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        visualEffect.addSubview(hostingView)

        self.contentView = visualEffect

        // Pin hosting view to visual effect view edges
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: visualEffect.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: visualEffect.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: visualEffect.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor),
        ])

        // Size window to fit SwiftUI content
        let size = hostingView.fittingSize
        setContentSize(size)
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func resignMain() {
        super.resignMain()
        close()
    }
}
