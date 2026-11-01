# Spotless — Regression Test Report

Date: 2026-11-01. No physical Android device and no AVD/emulator is available
on this machine. Anything that requires running the APK is marked **BLOCKED**,
not PASS.

## Automated checks (final source)

| Check | Command | Result |
|---|---|---|
| Static analysis | `flutter analyze` | **PASS** — 0 issues (log gitignored) |
| Unit/widget tests | `flutter test` | **PASS** — 27/27 (log gitignored) |
| Debug build | `flutter build apk --debug` | **PASS** |
| Release build | `flutter build apk --release` | **PASS**, release-signed |
| APK signature | `apksigner verify --print-certs` | **PASS** (certificate CN=Spotless) |
| Manifest/package | `aapt dump badging` | **PASS** (`com.nandhu.spotless`, 0.1.0, SDK 24–36) |
| Python syntax | `python -m py_compile ytdlp.py` | **PASS** |
| Install/launch | `adb install` / launch | **BLOCKED** — no device/emulator |

## Test suite inventory (27 tests)

| File | Tests | Covers |
|---|---:|---|
| `test/session_test.dart` | 14 | 8 session-continuity cases, ratings + consistency across sessions, duration-weighted skips, LRC/plain lyrics parsing |
| `test/discovery_test.dart` | 5 | Local acoustic similarity/ranking, similar discovery, candidate promotion, stale cleanup, external-provider failure isolation |
| `test/shuffle_test.dart` | 2 | Normal shuffle preserves queue/current; artist spacing |
| `test/library_scanner_test.dart` | 2 | Rescan preserves user data and clears deleted paths; missing file with no YouTube id becomes missing |
| `test/download_manager_test.dart` | 4 | Queue serialization/progress, cancellation of a running task, retry after failure, duplicate enqueue deduplication |

New in this pass: `library_scanner_test.dart` (2), `download_manager_test.dart`
(4) and one extra discovery test (provider failure). Existing tests were
updated for the removed Qloo provider.

## Required regression checklist

### Application

| Item | Status | Notes |
|---|---|---|
| Fresh launch | BLOCKED | No device/emulator |
| Restart / persistence | BLOCKED | drift persistence not exercised on device |
| Navigation between tabs/screens | BLOCKED | Static review only |
| Background/foreground transition | BLOCKED | Requires device |
| Permission handling (notifications, storage) | BLOCKED | Runtime flow added, not executed |

### Playback

| Item | Status | Notes |
|---|---|---|
| Stream a YouTube track | BLOCKED | Requires device + network + Python runtime |
| Play a downloaded/local track | BLOCKED | No device |
| Pause / resume | BLOCKED | Logic reviewed; session activity wired |
| Seek | BLOCKED | Logic reviewed |
| Next / previous | BLOCKED | Engine fixes reviewed; repeat-all wrap added |
| Queue add/remove/reorder | BLOCKED | Shuffle-index math is unit-tested indirectly by shuffle tests |
| Shuffle (normal/smart) | PASS (unit) | Queue permutation and artist spacing |
| Repeat off/all/one | BLOCKED | Logic reviewed |
| Background playback | BLOCKED | Requires device |
| Notification/lock-screen controls | BLOCKED | Manifest/service reviewed, media index fix applied |
| Audio interruption / focus | BLOCKED | audio_service/just_audio default handling |

### Downloads

| Item | Status | Notes |
|---|---|---|
| Start download / progress | BLOCKED | New queue and progress UI; Python path not executed |
| Cancel download | BLOCKED | Cancel flag + partial cleanup reviewed |
| Retry failed download | BLOCKED | New queue retry path |
| Verify downloaded file | BLOCKED | Requires device |
| Play downloaded file | BLOCKED | Local path resolution hardened |
| Restart and verify persistence | BLOCKED | Completed rows persist by design; queue itself is in-memory |

### Lyrics

| Item | Status | Notes |
|---|---|---|
| Load synced lyrics | PASS (parser) / BLOCKED (fetch) | LRC parser tested; LRCLIB fetch needs device |
| Load unsynced lyrics | PASS (parser) | Plain-text fallback tested |
| Active-line highlight/auto-scroll | BLOCKED | Widget logic reviewed |
| Click-to-seek | BLOCKED | Implemented in `SyncedLyricsView` |
| Manual refetch | BLOCKED | UI + force flag reviewed; duration rejection coded |
| Change tracks (race) | BLOCKED | Request-token guard added; not executed |

### Playlists

| Item | Status | Notes |
|---|---|---|
| Create / rename / delete | BLOCKED | No device |
| Add/remove/reorder tracks | BLOCKED | Repository/UI reviewed |
| Play playlist | BLOCKED | No device |
| Restart persistence | BLOCKED | drift schema unchanged; seed insert made idempotent |

### Recommendations / taste

| Item | Status | Notes |
|---|---|---|
| Generate recommendations | PASS (unit) | Local provider + failure isolation |
| Rate a track | PASS (unit, service level) / BLOCKED (UI) | Rating events tested |
| Reject recommendation | BLOCKED | UI action reviewed |
| Feedback persistence | PASS (unit) | Rating/skip events persisted in tests |
| Session continuity | PASS (unit) | 8 cases per specification |
| Long-term taste updates | PASS (unit) | Consistency across sessions |
| Browsing does not start session | PASS (code review) | `getActiveSession` only; no dedicated test |

### Android

| Item | Status | Notes |
|---|---|---|
| Notification / lock screen | BLOCKED | No device |
| Background playback | BLOCKED | No device |
| Permissions | BLOCKED | Manifest static check PASS |
| Storage access / folder picker | BLOCKED | `file_picker` flow not executed |
| Process recreation | BLOCKED | No device |
| Device restart | BLOCKED | No device |

## What static validation did cover

- All Dart source compiles in both debug (JIT) and release (AOT) modes.
- Chaquopy packages CPython 3.12, `yt-dlp==2026.7.4`, `mutagen==1.48.1` and the
  app's `ytdlp.py` for `arm64-v8a` and `x86_64`.
- Release APK is signed with the generated release certificate, not the debug
  key.
- Manifest contains the Android 14 media-playback foreground-service permission
  and the `AudioService`/`MediaButtonReceiver` declarations.
- No analyzer warnings, no TODO/FIXME left in changed code paths.
- Python compiles successfully; JSON/return contracts are strings on both sides.

## Limitations

- Runtime behaviour of yt-dlp against YouTube cannot be verified from a build
  alone. The pinned version is the supported update path.
- Database migration from a real user installation was not exercised because
  no database file or device is present. The schema itself was not changed in
  this pass; only insert semantics for seeded playlists changed.
- Manual UI review was static; screenshots/visual review were not requested and
  no emulator exists.
