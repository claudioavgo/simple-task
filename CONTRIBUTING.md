# Contributing to Simple Task

Thanks for your interest in contributing! This guide covers everything you need to get started.

## Getting Started

1. Fork the repo and clone your fork
2. Open `Simple/Simple.xcodeproj` in Xcode 16+
3. Build and run with ⌘R
4. Make your changes on a new branch

## Branch Naming

Use prefixes to describe the type of change:

```
feat/short-description     — new feature
fix/short-description      — bug fix
refactor/short-description — code refactoring (no behavior change)
docs/short-description     — documentation only
chore/short-description    — tooling, CI, dependencies
```

Examples:
```
feat/drag-and-drop-reorder
fix/today-count-mismatch
refactor/extract-date-helpers
docs/update-architecture-section
```

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short description>

<optional body>
```

### Types

| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code change that doesn't fix a bug or add a feature |
| `docs` | Documentation only |
| `style` | Formatting, missing semicolons, etc. (no logic change) |
| `test` | Adding or updating tests |
| `chore` | Build process, dependencies, CI |

### Scope (optional)

Use the area of the codebase: `model`, `views`, `capture`, `sidebar`, `menubar`, `utils`.

### Examples

```
feat(model): add whenDate for Things 3-style scheduling
fix(capture): align shortcut text in toolbar pills
refactor(views): extract date formatting into shared utility
docs: update README with keyboard shortcuts table
chore: add SwiftLint configuration
```

### Rules

- Use imperative mood: "add feature" not "added feature"
- Keep the first line under 72 characters
- Reference issues when applicable: `fix(sidebar): correct count for today (#12)`

## Pull Requests

1. Create your branch from `main`
2. Make sure the project builds without warnings
3. Keep PRs focused — one feature or fix per PR
4. Write a clear description of what changed and why
5. Link related issues

### PR Title

Follow the same format as commit messages:
```
feat(model): add deadline date support
```

## Code Style

- Follow existing patterns in the codebase
- Use `// MARK: -` comments to organize view sections
- Use `@ViewBuilder` computed properties to decompose complex views
- Shared helpers go in `Utilities/` (e.g., `DateFormatting.swift`)
- All UI text in English
- Use `try? modelContext.save()` after every SwiftData mutation

## Project Structure

```
Simple/Simple/
├── App/          — Entry point, scenes, app delegate
├── Model/        — SwiftData models and enums
├── Views/        — All SwiftUI views
├── Utilities/    — Helpers, extensions, NSPanel
└── Resources/    — Assets, Info.plist, entitlements
```

When adding a new `.swift` file, you must also add it to the Xcode project file (`project.pbxproj`):
- Add a `PBXFileReference` entry
- Add a `PBXBuildFile` entry
- Add to the appropriate `PBXGroup`
- Add to the `PBXSourcesBuildPhase`

## Reporting Bugs

Open an issue with:
- macOS version
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable

## Feature Requests

Open an issue describing:
- The problem you're trying to solve
- Your proposed solution
- Any alternatives you considered

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
