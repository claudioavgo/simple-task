# Simple Task

A minimal, Things 3-inspired task manager for macOS. Lives in your menu bar with a global quick capture shortcut.

![macOS](https://img.shields.io/badge/macOS-15.0+-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![License](https://img.shields.io/badge/license-MIT-blue)

## Features

- **Menu Bar App** — Always accessible from your menu bar
- **Quick Capture** (`⌥ Space`) — Spotlight-style floating panel to capture tasks instantly
- **Smart Lists** — Inbox, Today (Hoje), Later (Depois) with task counts
- **Categories** — Create custom categories with icons and colors to organize tasks
- **Main Window** — Full Things 3-style interface with sidebar navigation
- **Context Menus** — Move tasks between sections, assign categories, delete
- **Persistence** — SwiftData-backed local storage

## Screenshots

```
┌─────────────────────────────────────────────────┐
│  Simple                                         │
│ ┌───────────┬───────────────────────────────────┤
│ │  LISTAS   │  Inbox                        3   │
│ │  ☐ Inbox  │  ───────────────────────────────  │
│ │  ☀ Hoje   │  ☐ Comprar leite                  │
│ │  ☾ Depois │  ☐ Enviar email pro João           │
│ │           │  ☐ Revisar PR do projeto           │
│ │  CATEGORIAS                                   │
│ │  🏠 Casa  │  ── Concluídas ─────────────────  │
│ │  💼 Work  │  ☑ Fazer café                     │
│ │           │                                   │
│ │  + Nova   │  + Nova tarefa...                 │
│ └───────────┴───────────────────────────────────┘
```

## Requirements

- macOS 15.0+
- Xcode 16+
- Swift 6.0

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/claudioavgo/simple-task.git
   cd simple-task
   ```

2. Open the Xcode project:
   ```bash
   open Simple/Simple.xcodeproj
   ```

3. Build and run (`⌘R`)

## Architecture

```
Simple/
├── App/
│   ├── SimpleApp.swift          # App entry point, scenes & model container
│   └── AppDelegate.swift        # Keyboard shortcuts & floating panel
├── Model/
│   ├── TodoItem.swift           # Task model (SwiftData)
│   ├── TodoSection.swift        # Inbox/Today/Later enum
│   └── Category.swift           # User-created categories (SwiftData)
├── Views/
│   ├── MainView.swift           # NavigationSplitView (sidebar + detail)
│   ├── SidebarView.swift        # Lists & categories sidebar
│   ├── TaskListView.swift       # Filtered task list with inline add
│   ├── TaskRowView.swift        # Individual task row with category badge
│   ├── QuickCaptureView.swift   # ⌥Space quick capture modal
│   ├── MenuBarView.swift        # Menu bar popover
│   ├── SectionView.swift        # Section grouping for menu bar
│   └── NewCategorySheet.swift   # Create category sheet
├── Utilities/
│   ├── FloatingPanel.swift      # NSPanel for Spotlight-style UI
│   └── KeyboardShortcuts+Names.swift
└── Resources/
    ├── Assets.xcassets
    ├── Info.plist
    └── Simple.entitlements
```

### Tech Stack

- **SwiftUI** — Declarative UI
- **SwiftData** — Local persistence
- **AppKit** — Menu bar integration, floating panels
- **[KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts)** — Global hotkey management

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌥ Space` | Quick capture |
| `⌘1` / `⌘2` / `⌘3` | Select Inbox / Today / Later (in quick capture) |
| `⏎` | Save task |
| `⎋` | Close quick capture |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by [Things 3](https://culturedcode.com/things/) by Cultured Code
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) by Sindre Sorhus
