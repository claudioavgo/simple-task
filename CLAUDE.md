# Simple Task — Project Guide

## Overview
Minimal Things 3-inspired task manager for macOS. Menu bar app with a global quick capture shortcut (⌥Space) and a full main window with sidebar navigation.

## Tech Stack
- **SwiftUI** + **SwiftData** — UI and persistence
- **AppKit** — Menu bar integration, floating panels (NSPanel)
- **KeyboardShortcuts** (SPM) — Global hotkey management
- **Swift 6.0** with strict concurrency, macOS 15.0+

## Project Structure
```
Simple/Simple/
├── App/
│   ├── SimpleApp.swift          — @main, scenes, ModelContainer setup
│   └── AppDelegate.swift        — Global hotkey listener, FloatingPanel lifecycle
├── Model/
│   ├── TodoItem.swift           — @Model: task with section, dates, category
│   ├── TodoSection.swift        — Enum: Inbox, Today, Later, Done
│   └── Category.swift           — @Model: user-created areas (icon + color)
├── Views/
│   ├── MainView.swift           — NavigationSplitView root
│   ├── SidebarView.swift        — Lists + categories sidebar
│   ├── TaskListView.swift       — Filtered task list + inline add
│   ├── TaskRowView.swift        — Single task row with badges + context menu
│   ├── QuickCaptureView.swift   — ⌥Space floating capture modal
│   ├── MenuBarView.swift        — Menu bar popover
│   ├── SectionView.swift        — Section grouping (used in menu bar)
│   └── NewCategorySheet.swift   — Create category sheet
├── Utilities/
│   ├── FloatingPanel.swift      — NSPanel subclass (Spotlight-style)
│   ├── KeyboardShortcuts+Names.swift — Shortcut definitions
│   ├── DateFormatting.swift     — Shared date helpers, Color+Hex, SectionStyle
│   └── KeyboardModifiers.swift  — ⌘+Number key monitor
└── Resources/
    ├── Assets.xcassets, Info.plist, Simple.entitlements
```

## Key Architecture Decisions

### Date System (Things 3-inspired)
- `whenDate` — "When" date: the day a task surfaces in Today. Auto-promotes via `effectiveSection`.
- `deadline` — Hard due date. Shows countdown badge on task row.
- `effectiveSection` — Computed: if whenDate ≤ today → returns `.today` regardless of stored section.
- Sidebar counts use `effectiveSection` so auto-promoted tasks appear in Today.

### Sections vs Categories
- **Sections** (TodoSection) are fixed: Inbox, Today, Later, Done. Stored as `sectionRaw` string.
- **Categories** (Category) are user-created areas. A task can optionally belong to one category.
- Filtering: section views use `effectiveSection`; category views filter by relationship.

### Quick Capture Modal
- FloatingPanel (NSPanel) with NSVisualEffectView blur
- Quick date actions only (Today, Tomorrow, Next Monday/Friday) — no calendar picker
- Section pills with ⌘1/2/3 shortcuts
- Category menu appears only when categories exist

### App Lifecycle
- MenuBarExtra is always present
- Main Window (id: "main") opened via "Open Simple" button or menu bar
- Closing the window keeps the app running in the menu bar
- AppDelegate owns the FloatingPanel for quick capture

## Conventions
- **Language**: All UI text in English
- **Code style**: MARK comments for sections, `@ViewBuilder` for conditional views
- **Date logic**: Always use `Calendar.current.startOfDay(for:)` for date comparisons
- **Saving**: `try? modelContext.save()` after every mutation
- **Colors**: Hex strings stored in model, converted via `Color(hex:)`

## Building
```bash
cd Simple && xcodebuild -scheme Simple -configuration Debug build
```

## Common Tasks
- **Add a new view**: Create in Views/, add to pbxproj (PBXFileReference + PBXBuildFile + PBXGroup + Sources phase)
- **Add a new utility**: Create in Utilities/, same pbxproj steps
- **Change model schema**: Update model + add to Schema array in SimpleApp.swift. Delete local store if migration needed.
- **Delete local store**: `rm ~/Library/Application\ Support/default.store*`
