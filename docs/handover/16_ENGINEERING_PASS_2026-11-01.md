# 16 — Engineering Pass Addendum (2026-11-01)

This document supersedes stale state in the original dossier. The detailed
record lives in `docs/development/`.

## State after this pass

- Branch `main`, code commits pushed to `origin/main`; documentation commit
  follows.
- `flutter analyze`: 0 issues.
- `flutter test`: 27/27 (added library-scanner and download-queue tests).
- Debug and release APKs built; release is signed with a local release key,
  not the debug key.
- No Android device/AVD on the build machine: install/launch/manual audio tests
  are BLOCKED.

## What changed

- **Library**: non-destructive rescans, recursive multi-format scanning,
  stable playlist-only ids, deleted-file detection, full metadata merge.
- **Playback**: correct queue/shuffle indices across reorder/insert/remove,
  non-blocking `play()`, safe crossfade/stop, bounded failure recovery,
  correct media-session indices, session heartbeat and completion feedback.
- **Downloads**: serialized queue with progress, cancel, retry and a visible
  page; cancellation removes partial files.
- **YouTube**: duration/title/artist-scored canonical candidate search; no
  blind first-result selection; lazy resolution for rows without an id.
- **Lyrics**: local-first, >8 s duration-mismatch rejection, no cross-track
  races, manual refetch with real UI states.
- **Discovery**: provider failures isolated; session vs long-term seeds;
  browsing no longer creates a session; streamed candidates feed penalties.
- **Removed**: the invented Qloo integration and its key field.
- **Build**: configurable Chaquopy Python path; pinned mutagen; Android 14
  media-playback permission; gitignored release keystore/key properties.

## Corrections to the original dossier

- Qloo no longer exists; do not configure or document it as an active provider.
- The release APK is no longer debug-signed when `app/android/key.properties`
  exists. That file and `spotless-release.jks` are local and gitignored.
- The Chaquopy Python path is no longer hardcoded; set `CHAQUOPY_PYTHON` or
  have Python 3.12 on `PATH`.
- Tests are 27, not 20, and include `library_scanner_test.dart` and
  `download_manager_test.dart`.

## Still relevant warnings

The original warnings about passing `headers: null` for local files, never
awaiting `play()`, avoiding name-based playlist logic, and the one-hour session
rules remain valid.
