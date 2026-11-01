# Spotless — Final Engineering Handover

Date: 2026-11-01. Branch: `main`. Repository:
https://github.com/raviaddagalla/spotless.

## 1. Executive summary

Spotless remains a Flutter + drift + just_audio + audio_service Android player
with YouTube streaming/download through embedded CPython/yt-dlp. No rewrite and
no framework migration was performed.

This pass fixed the defects that could lose user data or make playback
unreliable: library rescans no longer wipe play counts/ratings/likes/downloads,
queue/shuffle mutations no longer point the engine at the wrong track, playback
no longer deadlocks on `play()`, crossfades no longer leave audio running or
skip tracks, downloads are serialized and cancellable, lyrics matching is
duration-aware, and session continuity has a heartbeat. The invented Qloo
integration was removed.

The app analyzes cleanly, 27 tests pass, and debug + release APKs were built.
The release APK is signed with a newly generated local release key (not the
debug key). No Android device or emulator exists on this machine, so runtime
installation/audio checks are **BLOCKED**, not claimed.

## 2. Audit scope

- 60 hand-written Dart files (13,803 lines) reviewed, plus generated drift code
  excluded from line review.
- `MainActivity.kt` (150 lines) and `ytdlp.py` (596 lines) reviewed.
- Gradle, manifest, network config, pubspec, `.gitignore`, tests and handover
  dossier reviewed.
- Issue register: 47 entries (see `FULL_CODEBASE_AUDIT.md`), 43 fixed, 4 open
  or accepted limitations.
- Baseline (`BASELINE_AUDIT.md`): analyzer clean, 20 tests passing, debug build
  successful; release was debug-signed; Python path hardcoded.

## 3. Bugs fixed (representative)

| Fix | Files |
|---|---|
| Non-destructive rescan preserving user data; stable playlist-only ids; recursive multi-format scan; deleted-file detection; full CSV metadata merge | `core/services/library_scanner.dart` |
| Lazy canonical YouTube resolution; local-file existence check; atomic play counts; album+artist grouping; lyrics duration guard | `core/services/music_repository.dart` |
| Queue index captured before order swap; permutation validation; shuffle index shift on insert/remove; bounded load-failure loop; session heartbeat; completion feedback | `core/audio/audio_engine.dart`, `core/state/player_controller.dart` |
| Unawaited `play()`, detach-before-stop, stop both players, media-session queue index, repeat-all wrap, paused crossfade | `core/audio/audio_engine.dart` |
| Serialized download queue, cancel/retry/progress, partial-file cleanup | `core/services/download_manager.dart`, `downloader.dart`, `ytdlp.py`, `ui/downloads_page.dart` |
| Separate Python executors, bounded timeouts, explicit Callable, cancel endpoint | `MainActivity.kt`, `yt_bridge.dart`, `ytdlp.py` |
| Duration-aware lyrics match, local `.lrc` preservation, no stale/out-of-order lyrics, manual refetch states | `music_repository.dart`, `ytdlp.py`, `lyrics_page.dart`, `player_controller.dart` |
| Rating request guard, rollback and tappable compact mode | `ui/widgets/rating_widget.dart` |
| Provider failure isolation, session-vs-long-term seeds, no session on browse, stream feedback | `discovery_service.dart`, `discovery_page.dart` |
| Idempotent seeded playlists; playlist reorder persistence | `app_database.dart`, `playlist_songs_page.dart` |
| Startup error screen; proper provider wiring | `main.dart` |
| Removed fake Qloo provider | `qloo_provider.dart` (deleted), repository/settings/debug/docs |

## 4. PixelPlayer comparison

Inspected README, license, navigation, screens, feature documentation and
project structure of PixelPlayer (Kotlin/Compose/Media3). Its license is
**proprietary** and prohibits redistribution/derivatives, so no code, assets
or Compose implementations were copied; only product-level ideas were used.

Implemented/adapted: multi-format recursive library, non-destructive metadata,
album+artist artwork grouping, duration-aware lyrics matching and immersive
lyrics interaction (already present, now reliable), session vs long-term taste
seeds, queue drag reorder (already present, fixed).

Deliberately rejected for now: equalizer, gapless playback, home-screen widget,
Android Auto, Chromecast, AI playlists, lyrics editing, tag-editor UI,
backup/restore. Reasons and complexity are in `PIXELPLAYER_GAP_ANALYSIS.md`.

## 5. New / changed behaviour

- **Downloads** — Settings → Diagnostics → Downloads shows a live queue.
  Tasks run one at a time, report progress, can be cancelled (partial file
  removed) and retried. Import dialogs can be cancelled.
- **Canonical matching** — candidate scoring uses exact artist/title phrases,
  duration, channel and negative keywords; low-confidence matches fail instead
  of downloading a random live/cover video.
- **Lyrics** — manual refetch (`Find lyrics`) uses a force path, shows loading,
  no-match and error states, and rejects recordings more than 8 seconds off.
- **Session model** — playback heartbeat every 5 minutes; pause, resume, skip,
  previous and queue jump count as listening activity. Browsing Discovery does
  not start a session. No time-of-day profiles exist.
- **Storage** — library browsing requests All Files Access on Android 11+ and
  opens system settings when denied; legacy storage is requested on older
  versions.
- **Media session** — notification/lock-screen controls now report library
  queue positions and stop truly silences both players.

## 6. Architecture

No new playback engine or state source. `AudioEngine` remains authoritative for
audio/media session; `PlayerController` remains authoritative for library-order
queue/shuffle and taste feedback. A new `DownloadManager` isolates download
queuing from `MusicRepository`. Schema version was **not** changed; only seeded
playlist insertion became idempotent. No destructive migration exists.

## 7. Testing

| Check | Result |
|---|---|
| `flutter analyze` | 0 issues |
| `flutter test` | 27/27 pass |
| Python `py_compile` | pass |
| Debug APK | built |
| Release APK | built, release-signed |
| `apksigner verify` | pass (CN=Spotless) |
| `aapt dump badging` | `com.nandhu.spotless`, 0.1.0, SDK 24–36 |
| Install/launch/manual audio | **BLOCKED** — no device/AVD |

Full checklist: `REGRESSION_TEST_REPORT.md`.

## 8. APKs

| File | Size | SHA-256 |
|---|---:|---|
| `artifacts/android/Spotless-0.1.0-debug.apk` | 204,225,063 B | `e3594365ee5247a429f69e8a6c0a5f5b8818611ed3264f3ae939553a9dc07306` |
| `artifacts/android/Spotless-0.1.0-release.apk` | 87,834,851 B | `78bd020b8e803f5caa76b236066e949f97acd3e28d0ffbbb26db1e2db30e99f3` |

APKs and checksums are local and gitignored (see `BUILD_REPORT.md`). Release
signing key: `app/android/spotless-release.jks`, credentials in
`app/android/key.properties`; both gitignored. **Back up this keystore** — it is
required for future updates and is not recoverable from Git.

## 9. GitHub

Code commits pushed to `origin/main`:

- `d009df0` — `fix(library): preserve user data and harden acquisition`
- `efb6449` — `fix(playback): keep queue, crossfade and session state consistent`
- `d5ee53b` — `fix(lyrics): guard against stale and mismatched lyrics`
- `c09dac5` — `fix(android): make the Python bridge portable and cancellable`
- `19aeb96` — `test: cover library preservation and download queue behaviour`
- Documentation commit follows this file.

Push verified with `git ls-remote origin refs/heads/main` returning
`19aeb96a414e573b3f2a26a14fb770e0f9ef9b80` before the documentation commit.
No force-push, no branch deletion, no history rewrite of existing commits.

## 10. Remaining problems

1. **No on-device verification.** Install, launch, notification, lock screen,
   background audio, permissions, downloads and process recreation are blocked.
2. **yt-dlp is an external dependency.** YouTube changes can break streaming;
   update by bumping the pinned wheel and rebuilding.
3. **Download queue is in-memory.** Completed files/rows persist, but an
   interrupted queue must be re-created. No HTTP resume.
4. **Synchronous library scan.** `listSync` can jank on very large libraries.
5. **No backup/restore.** A reinstall or data clear loses ratings, playlists
   and session history.
6. **All Files Access** remains for arbitrary folder libraries (Play policy
   risk if published).
7. **Release fallback.** Without `key.properties`, Gradle debug-signs the
   "release" build; that APK is not distributable.
8. **No widget/instrumentation tests.** UI and Android service behaviour are
   verified by analysis/build only.

## 11. Recommended next steps

1. Install the release APK on the physical device, run the regression
   checklist, and verify audio focus, notification controls, downloads and
   lyrics against the live network.
2. Add backup/restore for the drift database + playlists (versioned JSON) and
   test a real v3 database upgrade.
3. Move library scanning to `Isolate`/async IO and stream progress without
   blocking the UI.
4. Persist the download queue and add resume/retry policy.
5. Add widget tests for queue/shuffle mutations and a small instrumentation
   test for the audio service handshake.
6. Consider configurable crossfade duration and optional gapless playback only
   after measuring real user impact.

## 12. Documentation index

- `docs/development/BASELINE_AUDIT.md`
- `docs/development/FULL_CODEBASE_AUDIT.md`
- `docs/development/PIXELPLAYER_GAP_ANALYSIS.md`
- `docs/development/IMPLEMENTATION_PLAN.md`
- `docs/development/REGRESSION_TEST_REPORT.md`
- `docs/development/BUILD_REPORT.md`
- `docs/development/CHANGELOG.md`
- `docs/development/FINAL_HANDOVER.md` (this file)
