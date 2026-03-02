# Simple Task

A minimal, Things 3-inspired task manager for macOS. Lives in your menu bar with a global quick capture shortcut.

![macOS](https://img.shields.io/badge/macOS-15.0+-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![License](https://img.shields.io/badge/license-MIT-blue)

## Features

- **Menu Bar App** — Always one click away from your system tray
- **Quick Capture** (<kbd>⌥</kbd> <kbd>Space</kbd>) — Spotlight-style floating panel to capture tasks instantly
- **Smart Lists** — Inbox, Today, Later with live task counts
- **Scheduling** — Set a "When" date and tasks auto-promote to Today when the day arrives
- **Deadlines** — Due dates with color-coded countdown badges (overdue, today, upcoming)
- **Categories** — User-created areas with custom SF Symbol icons and colors
- **Main Window** — Full Things 3-style NavigationSplitView with sidebar
- **Context Menus** — Move between sections, schedule, assign categories, delete
- **SwiftData Persistence** — Everything saved locally, no account required

## Quick Capture

The quick capture modal (<kbd>⌥</kbd> <kbd>Space</kbd>) provides:

- Section selection via pills (<kbd>⌘1</kbd> Inbox, <kbd>⌘2</kbd> Today, <kbd>⌘3</kbd> Later)
- Quick date scheduling (Today, Tomorrow, Next Monday)
- Deadline shortcuts (Today, Tomorrow, Next Friday)
- Optional category assignment
- <kbd>⏎</kbd> to save, <kbd>⎋</kbd> to close

## Requirements

- macOS 15.0+
- Xcode 16+
- Swift 6.0

## Getting Started

```bash
git clone https://github.com/claudioavgo/simple-task.git
cd simple-task
open Simple/Simple.xcodeproj
```

Build and run with <kbd>⌘</kbd> <kbd>R</kbd>.

## Architecture

```
Simple/Simple/
├── App/             Entry point, app delegate, scene configuration
├── Model/           SwiftData models — TodoItem, Category, TodoSection
├── Views/           SwiftUI views — main window, sidebar, task list, quick capture
├── Utilities/       FloatingPanel, keyboard helpers, date formatting, Color+Hex
└── Resources/       Assets, Info.plist, entitlements
```

### Date System

Inspired by Things 3's dual-date approach:

| Field | Purpose | Behavior |
|-------|---------|----------|
| `whenDate` | When should I start? | Auto-promotes task to Today when the date arrives |
| `deadline` | When is it due? | Color-coded badge — red (overdue), orange (today), yellow (soon) |

Tasks without dates stay in their assigned section. The `effectiveSection` computed property handles auto-promotion transparently.

### Tech Stack

| Layer | Technology |
|-------|------------|
| UI | SwiftUI |
| Persistence | SwiftData |
| Platform | AppKit (menu bar, floating panels) |
| Dependencies | [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) |

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| <kbd>⌥</kbd> <kbd>Space</kbd> | Open quick capture |
| <kbd>⌘1</kbd> / <kbd>⌘2</kbd> / <kbd>⌘3</kbd> | Inbox / Today / Later |
| <kbd>⏎</kbd> | Save task |
| <kbd>⎋</kbd> | Close quick capture |
| <kbd>⌘O</kbd> | Open main window (from menu bar) |
| <kbd>⌘Q</kbd> | Quit |

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on:

- Branch naming (`feat/`, `fix/`, `refactor/`, ...)
- Commit messages ([Conventional Commits](https://www.conventionalcommits.org/))
- Pull request process
- Code style guidelines

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.

## License

MIT License — see [LICENSE](LICENSE) for details.

## Acknowledgments

- Inspired by [Things 3](https://culturedcode.com/things/) by Cultured Code
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) by Sindre Sorhus
