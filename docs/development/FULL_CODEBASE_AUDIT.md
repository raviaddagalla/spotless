# Spotless — Full Codebase Audit

Date: 2026-11-01. Scope: every hand-written file in `app/lib`, the Kotlin
bridge, the embedded Python service, Android build/manifest configuration,
tests and build scripts. Generated `app/lib/core/db/app_database.g.dart` was
excluded from line-by-line review (7,289 generated lines); its source of truth
(`tables.dart`, `app_database.dart`) was reviewed.

## 1. Source inventory

60 hand-written Dart files (13,803 lines), 2 native service files (746 lines),
5 test files (811 lines), plus Gradle/manifest/config.

| Layer | Files | Responsibility |
|---|---|---|
| `core/audio` | 1 | `AudioEngine` — just_audio players, audio_service handler, queue/order, crossfade, media session |
| `core/config` | 1 | Build-time/runtime configuration |
| `core/csv` | 1 | RFC-4180-ish Spotify CSV parsing |
| `core/db` | 2 (+generated) | drift schema, 15 tables, seed playlists |
| `core/lyrics` | 1 | LRC parser |
| `core/models` | 2 | Lyrics and song-status value types |
| `core/services` | 13 | Repository, library scanner, discovery/recommendation, Last.fm, ratings, feedback, sessions, downloads, covers |
| `core/state` | 1 | `PlayerController` — authoritative UI playback/queue state |
| `core/youtube` | 1 | MethodChannel bridge to Python |
| `ui` pages | 18 | Home, library, albums, artists, playlists, search, player, lyrics, discovery, settings, downloads, debug |
| `ui/theme` | 4 | Colors, typography, Material 3 theme, album-art palette |
| `ui/widgets` | 14 | Tiles, sliders, mini player, rating, lyrics view, pickers |
| native | 2 | `MainActivity.kt` (Chaquopy bridge), `ytdlp.py` (search/extract/download/lyrics/tags) |
| tests | 5 | Discovery, session/rating/lyrics, shuffle, library scanner, download queue |

Architecture: Flutter UI → `PlayerController` (queue, shuffle, session,
feedback) → `AudioEngine` (single authoritative playback engine) →
`MusicRepository` (drift + Python bridge) → SQLite / yt-dlp. No second
playback engine was introduced.

## 2. Issue register

Severity: **Critical** = crash/data loss/security/core broken; **High** =
major feature failure; **Medium** = wrong behaviour/performance/UX;
**Low** = cosmetic/maintainability. `Confirmed` means the defect was traced to
specific code, not inferred from a smell.

| ID | File | Reference | Issue | Severity | Impact | Correction | Status |
|---|---|---|---|---|---|---|---|
| AUD-001 | `core/services/qloo_provider.dart` | whole file | "Qloo" provider called endpoints that do not exist in Qloo's API and invented response shapes; key UI implied working recommendations | Critical (fake feature) | Misleading settings, guaranteed failed requests, wasted key | Removed provider, preference and settings field; Last.fm + local acoustic + taste ranking remain | Fixed |
| AUD-002 | `core/audio/audio_engine.dart` | `_syncQueue` | Current queue index captured *after* `_order` was replaced, so a shuffle/reorder pointed `_seq` at an unrelated track | Critical | Wrong song plays or previous/next jumps | Capture `previousQueueIndex` before mutation; validate permutation | Fixed |
| AUD-003 | `core/audio/audio_engine.dart` | `toggle`, `_load` | `await _player.play()` never completes until pause/end | Critical | UI hangs on play/next; controller futures stuck | Mark active then `unawaited(play())`; seek to zero when completed | Fixed |
| AUD-004 | `core/audio/audio_engine.dart` | `stop` | Stopped only the active player; a crossfade's auxiliary player kept playing | High | Audio continues after stop/notification stop | `_ensureIdle()` before stop; stop auxiliary; clear media item/queue | Fixed |
| AUD-005 | `core/audio/audio_engine.dart` | `_crossfadeTo` | Detached listeners *after* stopping old player; idle event treated as load failure, controller skipped an extra track | High | Every crossfade skipped a song | Detach before stop; reset `_activePlayback`; clean aux on failure | Fixed |
| AUD-006 | `core/audio/audio_engine.dart` | `_attach` | Re-attaching players without cancelling prior subscriptions leaked listeners and timers | High | Duplicate events/double advances after crossfades | `_detach()` first; cancel ticker | Fixed |
| AUD-007 | `core/audio/audio_engine.dart` | `previous` | Repeat-all did not wrap backwards from the first track | Medium | Previous at queue start restarts instead of wrapping | Wrap to last when repeat-all | Fixed |
| AUD-008 | `core/audio/audio_engine.dart` | `previous`/`next` | Crossfade ran while paused, briefly fading audio in | Medium | Unexpected sound when skipping while paused | Crossfade only when actually playing | Fixed |
| AUD-009 | `core/audio/audio_engine.dart` | `_publishState` | Media session `queueIndex` used shuffle order index against a library-order queue | High | Lock screen/notification shows wrong track/index | Publish queue index | Fixed |
| AUD-010 | `core/audio/audio_engine.dart` | completion | Natural completion only recorded at final queue end | High | Recommender never saw completion for auto-advanced tracks | `onTrackCompleted` for every natural end, once | Fixed |
| AUD-011 | `core/state/player_controller.dart` | `_onLoadError` | Failure advanced to next track with no limit | High | Offline queue looped forever | Consecutive-failure streak; pause with actionable error after full queue | Fixed |
| AUD-012 | `core/state/player_controller.dart` | `addNext`/`addToQueue`/`removeAt` | Shuffle order indices not shifted on insert/remove | High | Shuffle played wrong/duplicate/missing tracks | Index shift/insert/remove helpers + permutation self-heal | Fixed |
| AUD-013 | `core/state/player_controller.dart` | `_loadLyrics` | No request generation guard; slow lookup for track A overwrote track B's lyrics | High | Lyrics out of sync with current song | Request token + clear immediately + current-song check | Fixed |
| AUD-014 | `core/state/player_controller.dart` | session lifecycle | No heartbeat during continuous playback; pause/resume did not record activity | High | >1 h single-track listening incorrectly split sessions; resume kept stale session for up to a track change | 5-minute heartbeat while playing; record activity on pause/resume/skip/jump | Fixed |
| AUD-015 | `core/state/player_controller.dart` | download helpers | Download cancellation surfaced as generic failure; queue row not refreshed after download | Medium | Misleading error, still shown as streamable | Dedicated `DownloadCancelledException`; re-read row into queue | Fixed |
| AUD-016 | `core/services/music_repository.dart` | `resolve` | Songs without a YouTube id returned an empty source; missing local file could still be advertised as downloaded | Critical | "Nothing to play" for playlist/recommendation rows; dead tracks | Local file existence is the only local criterion; lazy canonical YouTube resolution; informative throw | Fixed |
| AUD-017 | `core/services/music_repository.dart` | lyric fetch | Remote LRCLIB result overwrote locally curated `.lrc`; no recording-duration validation | High | Wrong lyrics offsets for live/cover versions; lost local lyrics | Fetch only when absent (or explicit force); reject >8 s duration mismatch | Fixed |
| AUD-018 | `core/services/music_repository.dart` | `albums`/`songsByAlbum` | Albums grouped by title only (merged different artists) and dropped cover art; album detail ignored artist | Medium | Duplicate "Greatest Hits" albums mixed, missing artwork | Group by album+artist in Dart with representative art; artist-aware query | Fixed |
| AUD-019 | `core/services/music_repository.dart` | `recordPlay` | Read-modify-write of `playCount` from a stale row | Medium | Lost play counts | Atomic SQL increment | Fixed |
| AUD-020 | `core/services/music_repository.dart` | `importCsvFiles` | No cancellation path; import could not be interrupted | Medium | Frozen long imports | `isCancelled` callback; labelled outer break | Fixed |
| AUD-021 | `core/services/downloader.dart` | `download` | Python cancellation flag never surfaced; partial file could survive | High | Cancelled download looked failed/left orphan | `cancelled` result, delete partial, serialize queue | Fixed |
| AUD-022 | `core/services/download_manager.dart` | new | No queue; concurrent downloads shared one global progress file and one Python worker | High | Progress corruption, UI blocked, no retry/cancel | Serialized `DownloadManager` with queue/progress/cancel/retry/clear | Fixed |
| AUD-023 | `core/services/library_scanner.dart` | scan | `insertOrReplace` on every rescan reset play counts, likes, ratings, cached art and download status | Critical (data loss) | User data silently wiped whenever folder re-scanned | Read existing rows, merge metadata, preserve user-owned columns, explicit status recomputation | Fixed |
| AUD-024 | `core/services/library_scanner.dart` | scan | Paths that disappeared stayed `downloaded`; missing files without YouTube id became unplayable dead rows | High | Playback failures, wrong badges | `_existingFile`, status downgrade to missing/streamable | Fixed |
| AUD-025 | `core/services/library_scanner.dart` | scan | Only non-recursive `.mp3`; ignored flac/m4a/ogg/opus/wav, nested folders, case-sensitive lyric names | High | Most libraries invisible | Recursive scan, extension set, case-insensitive matching | Fixed |
| AUD-026 | `core/services/library_scanner.dart` | scan | Playlist-only rows keyed by position, deleted/reinserted each scan, duplicated; metadata refresh could overwrite downloads | High | Duplicate playlist tracks, unstable ids, data loss | Stable `pl:<track-uri>` ids, metadata-only updates, prune only truly stale rows | Fixed |
| AUD-027 | `core/services/library_scanner.dart` | scan | CSV import handled a narrow set of columns; no track number/ISRC/genres/audio features/explicit/added-at | Medium | Poor discovery/album ordering | Full metadata merge (nullable-aware, doesn't erase known values) | Fixed |
| AUD-028 | `core/services/discovery_service.dart` | provider loop | One failing external provider aborted all discovery, including local results | High | No recommendations when Last.fm key absent/offline | Per-provider try/catch; local always survives | Fixed |
| AUD-029 | `core/services/discovery_service.dart` | personalized | Opening Discovery created a listening session | Medium | Violated "browsing is not listening" requirement | Use `getActiveSession`, never create on browse | Fixed |
| AUD-030 | `core/services/discovery_service.dart` | personalized | Session taste and long-term taste were not combined distinctly | Medium | Current-session feedback could not influence radio | Session high ratings/recent plays seeds + long-term seeds, separate weighting | Fixed |
| AUD-031 | `core/db/app_database.dart` | seed playlists | Re-running creation inserts "Sleep"/"No Sleep" without conflict handling | High (crash) | Unique constraint on restart/migration | `InsertMode.insertOrIgnore` | Fixed |
| AUD-032 | `android/.../MainActivity.kt` | executor | One executor serialized downloads and interactive calls; no timeouts; `Future<PyObject>` null NPE risk; `shutdown` while calls in flight | Critical | Download froze all playback/search; hung calls never returned | Separate interactive/download/local pools; bounded `get` timeout; explicit `Callable`; daemon waiter | Fixed |
| AUD-033 | `android/.../ytdlp.py` | download | No cancel flag/partial cleanup; progress file non-atomic; broad swallowing; no canonical scoring | High | Stuck downloads, corrupt progress, wrong YouTube match | Cancel flag + cleanup + atomic progress; structured logging; scoring by artist/title/duration/negative keywords | Fixed |
| AUD-034 | `android/.../ytdlp.py` | lyrics | No duration-aware match selection | High | Live/cover lyrics attached to studio recording | Candidate scoring on title/artist/duration; expose `matched_duration`; Dart rejects >8 s | Fixed |
| AUD-035 | `core/youtube/yt_bridge.dart` | canonicalSearch | Bridge lacked canonical lookup/cancel; untyped raw casts | Medium | Fragile channel decoding | Added typed methods and safe defaults | Fixed |
| AUD-036 | `lib/main.dart` | startup | Async startup outside error zone; failure produced blank screen | High | App appears dead if DB/audio init fails | `runZonedGuarded` + `StartupError` screen + provider for downloads | Fixed |
| AUD-037 | `ui/widgets/rating_widget.dart` | `_loadRating`/`_rate` | Async rating response could land on the next song; errors left spinner stuck; compact rating was a dead label | High | Ratings applied to wrong song / impossible to rate from discovery | Request token, optimistic rollback, error SnackBar, tappable compact rating | Fixed |
| AUD-038 | `ui/lyrics_page.dart` | fetch | Manual LRCLIB fetch did not refresh controller lyrics; no loading/error state; match failure silent | Medium | User clicks "fetch" and sees nothing | Force fetch, reload, progress/error UI, reject notice | Fixed |
| AUD-039 | `ui/discovery_page.dart` | stream action | Streaming a recommendation did not mark it streamed or refresh discovery penalties | Medium | Same recommendation repeatedly offered | `markStreamed` before playback; open player | Fixed |
| AUD-040 | `android/app/build.gradle.kts` | chaquopy | Hardcoded `C:/Users/aravi/...` Python path; unpinned mutagen | High (portability) | Unbuildable on other machines/CI; non-reproducible | `CHAQUOPY_PYTHON` env with `python` fallback; pinned `mutagen==1.48.1` | Fixed |
| AUD-041 | `AndroidManifest.xml` | permissions | Missing `FOREGROUND_SERVICE_MEDIA_PLAYBACK` for Android 14+ | High | Foreground playback service start failure on modern Android | Permission added | Fixed |
| AUD-042 | `AndroidManifest.xml` | storage | `MANAGE_EXTERNAL_STORAGE` broad access | Medium (policy) | Play Store rejection risk; broad privacy surface | Kept (needed for arbitrary folder libraries), documented, runtime permission flow added | Accepted risk |
| AUD-043 | release config | signing | Release used debug key | High | Non-distributable/insecure release | Local keystore via gitignored `key.properties`; fallback warns and is documented | Fixed (local key) |
| AUD-044 | `.gitignore` | artifacts | APKs, keystores, logs and reference clone not ignored; build outputs could leak | Medium | Accidental commits of large/private files | Added ignores for APK/AAB/JKS/key.properties/logs/reference clone | Fixed |
| AUD-045 | `library_scanner.dart` | `listSync` | Synchronous recursive directory walk on the UI isolate | Medium (perf) | Jank on very large libraries | Not rewritten in this pass; scan already runs behind progress and is bounded by file count | Open |
| AUD-046 | `download_manager.dart` | queue | Queue is in-memory only; no resume after process death | Low | Interrupted downloads must be re-queued | Documented; completed downloads persist in SQLite/disk | Accepted limitation |
| AUD-047 | tests | whole suite | No widget/instrumentation tests; no scanner/download/widget coverage originally | Medium | Regressions in UI/Android plumbing undetected | Added scanner + regression tests; device tests remain blocked | Partially fixed |

## 3. Architectural observations (not changed)

- `MusicRepository` is a god object (~1,000 lines) but is the single seam
  between UI, drift and native. Splitting it now would touch every screen with
  no correctness benefit. Left as-is; new download concern was extracted into
  `DownloadManager` instead.
- `PlayerController` and `AudioEngine` both hold queue state. The engine is
  authoritative for audio/session; the controller is authoritative for
  library-order queue/shuffle. Synchronization goes through `_syncEngineQueue`;
  bugs in that seam were fixed rather than adding a third source of truth.
- Services never import UI; UI reads state through Provider. This boundary is
  intact.
- Recommendation providers share a `RecommendationProvider` interface; adding
  a provider is isolated.

## 4. Dependency and security review

- Dependencies are current Flutter-compatible versions; no known duplicate
  audio engine. `just_audio` + `audio_service` are the only playback stack.
- `permission_handler_android` is pinned to 13.0.1 via `dependency_overrides`
  (14.0.0 requires a compileSdk not installed); documented in `pubspec.yaml`.
- No API keys are committed. Last.fm key is user-entered and stored in
  SharedPreferences. Qloo key storage was removed.
- Network is HTTPS; `network_security_config` disables cleartext.
- Downloaded media and CSV libraries stay in app-private storage or the
  user-chosen folder. No upload path exists.
- The local release keystore and `key.properties` are gitignored and were never
  printed or committed.

## 5. Verification of this audit

- `flutter analyze` — clean.
- `flutter test` — 27/27 passing.
- `flutter build apk --debug` — success.
- `flutter build apk --release` — see `BUILD_REPORT.md`.
- On-device execution — BLOCKED (no device/emulator).
