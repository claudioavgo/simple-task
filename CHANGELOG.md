# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.1.0] - 2026-03-02

### Added
- Things 3-style date system with `whenDate` (scheduling) and `deadline` (due dates)
- Tasks with a `whenDate` of today or earlier auto-promote to the Today list
- Deadline countdown badges on task rows (color-coded: red, orange, yellow)
- Quick date actions in capture modal (Today, Tomorrow, Next Monday/Friday)
- Schedule and deadline context menu options on task rows
- `DateFormatting` shared utility for consistent date display
- `KeyboardModifiers` utility for ⌘+number key handling
- `SectionStyle` for consistent section color mapping
- `CLAUDE.md` project guide for AI-assisted development
- `CONTRIBUTING.md` with branch naming, commit, and PR conventions
- `CHANGELOG.md` following Keep a Changelog format

### Changed
- UI language switched from Portuguese to English throughout
- Quick capture modal rewritten from scratch — clean layout, no calendar picker, dropdown menus for dates
- Toolbar pills use fixed 24px height with monospaced shortcuts for consistent alignment
- Codebase refactored: extracted shared utilities, MARK comments, decomposed views
- `TodoSection` renamed: `.hoje` → `.today`, `.depois` → `.later`
- README rewritten with kbd tags, architecture tables, and quick capture docs

### Fixed
- Quick capture pill text wrapping/breaking at small sizes
- Shortcut text (⌘2) misaligned in Today pill due to font rendering

## [1.0.0] - 2026-03-02

### Added
- Menu bar app with system tray icon
- Quick capture modal via ⌥Space (Spotlight-style floating panel)
- Three built-in sections: Inbox, Today, Later
- Main window with NavigationSplitView (sidebar + detail)
- User-created categories with SF Symbol icons and colors
- Task management: create, complete, move between sections, delete
- Category assignment via context menu
- Inline task creation in both main window and menu bar
- SwiftData persistence with error recovery
- Keyboard shortcuts: ⌘1/2/3 for sections, ⏎ save, ⎋ close

[Unreleased]: https://github.com/claudioavgo/simple-task/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/claudioavgo/simple-task/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/claudioavgo/simple-task/releases/tag/v1.0.0
