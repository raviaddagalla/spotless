# Spotless — Implementation Plan

Derived from `FULL_CODEBASE_AUDIT.md` and `PIXELPLAYER_GAP_ANALYSIS.md`.
Executed autonomously in priority order; no rewrite, no framework migration,
one playback engine maintained.

## P0 — Critical correctness, data integrity, security

| # | Problem | Expected outcome | Files | Approach | Regression risk | Validation | Status |
|---|---|---|---|---|---|---|---|
| P0-1 | Rescan wiped play counts, likes, ratings, cached art, download state | Rescan updates metadata only | `core/services/library_scanner.dart` | Read existing rows; merge nullable-aware; recompute only status/path; stable `pl:` ids | Medium | `library_scanner_test.dart` (2 cases) | Done |
| P0-2 | Shuffle/reorder could load the wrong track | Queue order and audio index stay consistent | `core/audio/audio_engine.dart`, `core/state/player_controller.dart` | Capture index before order swap; validate permutation; shift shuffle indices on insert/remove | Medium | `shuffle_test.dart`; queue helpers reviewed | Done |
| P0-3 | `await play()` blocked callers for the whole song | Play/next return immediately | `core/audio/audio_engine.dart` | `unawaited(play())` with `_activePlayback` set first | Low | Debug/release builds; engine review | Done |
| P0-4 | Downloads serialized behind all playback calls; no cancellation | Interactive calls always responsive; cancel cleans up | `MainActivity.kt`, `ytdlp.py`, `downloader.dart`, new `download_manager.dart` | Three executors, bounded timeouts, cancel flag, atomic progress, serialized queue | Medium | Python syntax check; Dart analyze; download UI review | Done |
| P0-5 | Fake Qloo integration | No misleading provider | `qloo_provider.dart` (deleted), `music_repository.dart`, `settings_page.dart`, tests | Remove provider/preferences/UI | Low | Analyze + tests | Done |
| P0-6 | Duplicate seeded playlists could crash on insert | Idempotent seeding | `core/db/app_database.dart` | `InsertMode.insertOrIgnore` | Low | Existing session tests use the DB | Done |
| P0-7 | Playback failure looped through queue forever | Stop with actionable message after one full pass | `core/state/player_controller.dart` | Failure counter reset on ready | Low | Code review; no device to force failures | Done |
| P0-8 | No startup error surface | App shows reason instead of blank screen | `main.dart` | `runZonedGuarded` + `StartupError` | Low | Analyze/build | Done |
| P0-9 | Release debug-signed; hardcoded build Python path | Distributable local release; portable build | `app/build.gradle.kts`, `.gitignore` | Gitignored `key.properties`/JKS; env-configurable Python | Low | APK signature verified with `apksigner` | Done |

## P1 — Playback, downloads, lyrics, discovery reliability

| # | Problem | Expected outcome | Files | Approach | Regression risk | Validation | Status |
|---|---|---|---|---|---|---|---|
| P1-1 | Crossfade left aux audio running / skipped tracks | Clean crossfade, stop silences both players | `audio_engine.dart` | Detach before stop; reset state; cleanup on error | Medium | Code review; build | Done |
| P1-2 | Stop/notification stop incomplete | Stop clears media session and queue | `audio_engine.dart` | `_ensureIdle`, stop aux, clear item/queue | Low | Code review | Done |
| P1-3 | Media session index used shuffle index | Correct notification/lock-screen track | `audio_engine.dart` | Publish library queue index | Low | Code review | Done |
| P1-4 | Session split during continuous listening | Heartbeat maintains session | `player_controller.dart` | 5-min timer while playing; activity on pause/resume/skip | Medium | `session_test.dart` (8 continuity tests) | Done |
| P1-5 | Completion signal missing for auto-advanced tracks | Feedback covers every natural completion | `audio_engine.dart`, `player_controller.dart` | `onTrackCompleted` callback before advance | Low | Code review | Done |
| P1-6 | Local `.lrc` overwritten; wrong-recording lyrics | Local-first, duration-guarded remote fetch | `music_repository.dart`, `ytdlp.py`, `lyrics_page.dart` | Force flag, matched duration, >8 s reject, UI states | Medium | Existing LRC tests; code review | Done |
| P1-7 | Lyrics race between tracks | Only current track's lyrics displayed | `player_controller.dart`, `rating_widget.dart` | Request generation tokens | Low | Code review | Done |
| P1-8 | Wrong YouTube match (live/cover) | Best canonical candidate chosen | `ytdlp.py`, `yt_bridge.dart`, `music_repository.dart` | Title/artist/duration scoring, negative keywords, lazy resolve | Medium | Python compile; code review | Done |
| P1-9 | Provider failure killed discovery | Local results always returned | `discovery_service.dart` | Per-provider try/catch | Low | `discovery_test.dart` (5 cases) | Done |
| P1-10 | Browsing discovery created a session | Browsing is not listening | `discovery_service.dart` | `getActiveSession` only | Low | Code review | Done |
| P1-11 | Recommendation streaming not penalized | Repeated tracks suppressed | `ui/discovery_page.dart` | `markStreamed` before play | Low | Code review | Done |
| P1-12 | Album grouping merged artists, lost art | Correct albums with covers | `music_repository.dart`, `albums_page.dart`, `album_detail_page.dart` | Group by album+artist; artist-aware query | Low | Analyze/build | Done |
| P1-13 | Rating could apply to next song | Rating tied to song id with rollback | `rating_widget.dart` | Request token, error handling, tappable compact mode | Low | Analyze/build | Done |
| P1-14 | Stale play counts | Atomic increments | `music_repository.dart` | SQL `play_count + 1` | Low | Code review | Done |
| P1-15 | Download UI only blocked dialog | Visible queue, cancel, retry, clear | `download_manager.dart`, `downloads_page.dart`, `settings_page.dart`, `main.dart` | ChangeNotifier queue + page + provider | Low | Analyze/build | Done |

## P2 — PixelPlayer-inspired additions

| # | Item | Decision | Implementation |
|---|---|---|---|
| P2-1 | Non-destructive, multi-format, recursive library | Implemented | `library_scanner.dart` |
| P2-2 | Album+artist grid with artwork | Implemented | `music_repository.dart`, `albums_page.dart` |
| P2-3 | Duration-aware lyrics matching + manual refetch | Implemented | `ytdlp.py`, `music_repository.dart`, `lyrics_page.dart` |
| P2-4 | Session vs long-term recommendation seeds | Implemented | `discovery_service.dart` |
| P2-5 | Downloads queue | Implemented (Spotless need) | `download_manager.dart`, `downloads_page.dart` |
| P2-6 | Equalizer, gapless, widgets, Android Auto, Chromecast, AI playlists | Rejected for now | See gap analysis for rationale |

## P3 — UI refinement

| # | Item | Change | Status |
|---|---|---|---|
| P3-1 | Downloads discoverability | Settings entry with live pending count; empty/active/failed states | Done |
| P3-2 | Compact rating | Tappable 1–10 dialog instead of dead label | Done |
| P3-3 | Discovery stream action | Marks streamed and opens player | Done |
| P3-4 | Lyrics loading/failure | Spinner + explicit no-match/error text | Done |
| P3-5 | Album covers | Representative artwork on grid and detail | Done |
| P3-6 | Broader redesign | Not attempted; existing design system preserved | Deferred |

## P4 — Performance / maintainability

| # | Item | Change | Status |
|---|---|---|---|
| P4-1 | Portability | `CHAQUOPY_PYTHON` env fallback; pinned wheels | Done |
| P4-2 | Listener leaks | Cancel subscriptions/ticker before re-attach | Done |
| P4-3 | Test coverage | +7 tests (scanner, provider failure, download queue) → 27 total | Done |
| P4-4 | Scanner async I/O | Still uses `listSync`; acceptable for current library sizes | Open |
| P4-5 | Backup/restore | Not implemented; recommended next | Deferred |

## Validation gates

1. `flutter analyze` — 0 issues.
2. `flutter test` — 27/27.
3. `flutter build apk --debug` — success.
4. `flutter build apk --release` — success, signed with local release key.
5. On-device install/launch — blocked (no device/emulator).
