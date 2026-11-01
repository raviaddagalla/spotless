# 12 — Git and Development Workflow

> **Document Version**: 1.0.0  
> **Date**: November 1, 2026  

---

## 1. Git Repository State

- **Active Branch**: `main`
- **Upstream Remote**: `origin` (`https://github.com/raviaddagalla/spotless.git`)
- **Status**: Up to date with `origin/main`. Working tree clean.

### Recent Commit History
```
bf03589 fix(discovery): remove final modifier on late discoveryService to allow provider updates
b6c7f00 fix(build): configure Chaquopy for Python 3.12 runtime and build tools
cbd2a30 feat(ui): modernize UI with dynamic theming and Material 3 design system
4ce55f6 feat: complete personal music app engineering specification (all 14 phases)
```

---

## 2. Key Historical Architectural Milestones

1. **Commit `4ce55f6` (Specification Completion)**:
   - Implemented all 14 phases of the personal music app specification.
   - Introduced Schema v3 (Sessions, Ratings, PlaybackEvents, DiscoveryCandidates).
   - Created `SessionManager` (1-hour cutoff), `RatingService` (1-10 scale), `FeedbackService` (duration-weighted skips), and `DiscoveryService`.
   - Built canonical YouTube search scoring and LRCLIB synchronized lyrics matching.
2. **Commit `cbd2a30` (Modern UI Transformation)**:
   - Migrated to PixelPlayer-inspired Material 3 Expressive UI.
   - Integrated `PaletteGenerator` for dynamic album-art theme extraction (`DynamicThemeProvider`).
   - Built `WavySlider`, `RoundedControlButton` pills, frosted glass `MiniPlayer`, and collapsing hero headers.
3. **Commit `b6c7f00` (Python 3.12 & Chaquopy Upgrade)**:
   - Configured Chaquopy 17.0.0 to target Python 3.12 runtime and 64-bit ABIs (`arm64-v8a`, `x86_64`).
4. **Commit `bf03589` (Discovery Crash Fix)**:
   - Resolved `LateInitializationError` by removing `final` from `late DiscoveryService discoveryService` in `MusicRepository`.

---

## 3. Development Environment Conventions & Gotchas

### 3.1 Windows PowerShell 5.1 Shell Quirks
- The host machine runs **Windows PowerShell 5.1**.
- **Statement Separators**: PowerShell 5.1 does **NOT** support `&&`. Chaining commands with `&&` causes a fatal parser error (`InvalidEndOfLine`). Use `;` instead:
  ```powershell
  # CORRECT:
  git add .; git commit -m "feat: description"; git push origin main
  
  # INCORRECT:
  git add . && git commit -m "feat: description"
  ```
- **Flutter Binary**: Flutter is installed at `C:\Users\aravi\flutter\bin\flutter.bat` and is **not** on the default system `PATH`. Always invoke via PowerShell call operator `&`:
  ```powershell
  & "C:\Users\aravi\flutter\bin\flutter.bat" analyze
  ```
- **Binary Redirects**: PowerShell corrupts binary file redirection (e.g. `adb exec-out ... > db.sqlite`). Wrap in `cmd /c` when dumping binary files or SQLite databases.

### 3.2 Code Formatting & Static Analysis Conventions
- **Code Style**: Strictly adheres to `flutter_lints` (`^6.0.0`) defined in `app/analysis_options.yaml`.
- Always format code before committing:
  ```powershell
  & "C:\Users\aravi\flutter\bin\flutter.bat" format lib test
  ```
- Always ensure `flutter analyze` reports **0 issues**:
  ```powershell
  & "C:\Users\aravi\flutter\bin\flutter.bat" analyze
  ```

### 3.3 Conventional Commits
Commit messages must follow the Conventional Commits specification:
- `feat(scope): ...` for new capabilities.
- `fix(scope): ...` for bug fixes.
- `docs(scope): ...` for documentation updates.
- `refactor(scope): ...` for code refactoring with no functional change.
- `test(scope): ...` for unit/integration tests.
- `chore(scope): ...` for dependency, gradle, or maintenance updates.
