# Changelog — Spotless

All notable changes in this engineering pass. Version `0.1.0+1`.

## 2026-11-01 — Reliability, data integrity and release engineering

### Fixed — playback

- Fixed queue/shuffle desynchronization when a queue is replaced, reordered,
  inserted into or shortened. The engine now captures the current queue index
  before swapping the order and validates shuffle permutations.
- Fixed `play`/`next` hanging because `AudioPlayer.play()` was awaited; it only
  completes when playback pauses/stops.
- Fixed crossfade leaving the auxiliary player audible after stop and skipping
  an extra track because the old player's idle event was treated as a failure.
- Detach player subscriptions/ticker before re-attaching (listener leak).
- Crossfade now runs only while audio is playing; repeat-all wraps backwards.
- Media-session `queueIndex` now uses library order, not shuffle order.
- `stop()` clears both players, the media item and the media-session queue.
- Natural completion of every track is reported to feedback (not only the final
  queue track), and consecutive load failures stop after one full queue pass
  instead of looping forever.

### Fixed — library and data integrity

- Rescanning the library is now non-destructive: play counts, ratings, likes,
  cached artwork and in-app downloads survive metadata refreshes.
- Deleted files are detected; rows downgrade from `downloaded` to
  `streamable`/`missing` instead of pointing at a missing path.
- Recursive scanning and support for `.mp3`, `.m4a`, `.aac`, `.flac`, `.ogg`,
  `.opus`, `.wav`, `.webm` (previously non-recursive MP3 only).
- Playlist-only tracks use stable `pl:<track-uri>` ids; duplicates and stale
  rows are pruned without touching user data.
- Imported CSV metadata now covers album, duration, artwork, ISRC, track
  number, explicit flag, genres, audio features and timestamps, merging without
  erasing known values.
- Albums group by album **and** artist and carry representative cover art;
  album detail uses the same artist filter.
- Play counts increment atomically; duplicate seeded playlists no longer risk
  a unique-constraint failure.
- Removed the imaginary Qloo provider/API key UI; discovery relies on local
  acoustic similarity, Last.fm (optional key) and taste/session ranking.

### Fixed — downloads

- New serialized download queue (`DownloadManager`) with progress, cancel,
  retry, remove and clear-finished, exposed in Settings → Downloads.
- Cancellation now aborts the Python worker, removes the partial file and
  surfaces as "cancelled" rather than a generic failure.
- Interactive calls no longer queue behind downloads: separate executors and
  bounded timeouts in `MainActivity.kt`.
- Download status/path is refreshed into the active queue after completion.

### Fixed — lyrics

- Remote lyrics no longer overwrite local `.lrc` files unless explicitly
  forced by the user.
- LRCLIB matching is duration-aware; matches more than 8 seconds off the actual
  recording are rejected. Candidate scoring prefers title/artist/duration.
- Fixed a race where a slow lookup for the previous track replaced the current
  track's lyrics.
- Lyrics page shows loading, no-match and error states; manual refetch reloads
  the controller's lyrics and synchronizes the active line.
- Local `.lrc` matching is recursive and case-insensitive.

### Fixed — discovery and ratings

- One failing recommendation provider no longer aborts local discovery.
- Browsing Discovery no longer creates a listening session; current-session
  seeds and long-term taste seeds are combined deliberately.
- Streaming a recommendation marks it as streamed so repetition penalties apply.
- Rating widget: request-token guard prevents a rating landing on the next
  song, write failures roll back with a SnackBar, and the compact rating is now
  tappable (opens the 1–10 control).

### Added

- Visible download manager page with queue/progress/cancel/retry.
- Canonical YouTube candidate search/scoring (title, artist, duration, channel,
  negative keywords for live/cover/remix) and lazy resolution for songs with no
  YouTube id.
- Session heartbeat while playing; pause/resume/skip/jump count as listening
  activity, preserving the one-hour continuity rule.
- Startup error screen instead of a blank window; uncaught async errors are
  logged through `runZonedGuarded`.
- Regression tests for library rescan preservation and provider failure
  isolation and download queue (27 tests total).

### Build and Android

- Removed the hardcoded Windows Python path; `CHAQUOPY_PYTHON` overrides the
  interpreter, `python` on PATH is the fallback.
- Pinned `mutagen==1.48.1` and kept `yt-dlp==2026.7.4`.
- Added `FOREGROUND_SERVICE_MEDIA_PLAYBACK` for Android 14+.
- Added local release signing via gitignored `key.properties` + keystore; debug
  signing is only a documented fallback.
- Ignored APKs/AABs, keystores, key properties, logs and the PixelPlayer
  reference clone.
- Built and statically verified debug and release APKs (see `BUILD_REPORT.md`).

### Documentation

- Added baseline audit, full codebase audit, PixelPlayer gap analysis,
  implementation plan, regression report, build report, this changelog and the
  final handover.

### Known limitations

- No Android device/emulator available: install/launch and manual audio tests
  are blocked.
- Download queue is in-memory across process death; completed files persist.
- Library scan uses synchronous directory traversal; may jank on very large
  libraries.
- `MANAGE_EXTERNAL_STORAGE` remains for arbitrary folder libraries (Play Store
  policy risk for public distribution).
- yt-dlp/YouTube compatibility remains an external dependency; update by
  bumping the pinned wheel.
- PixelPlayer-inspired equalizer, widgets, gapless playback and backup/restore
  were deliberately not implemented (see gap analysis).
