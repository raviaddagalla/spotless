# 10 — Current Status and Bug Register

> **Document Version**: 1.0.0  
> **Date**: November 1, 2026  

> **Update:** the engineering pass summarized in
> [16_ENGINEERING_PASS_2026-11-01.md](16_ENGINEERING_PASS_2026-11-01.md) fixed
> additional queue, crossfade, library-data loss, lyrics and download issues.
> See `docs/development/FULL_CODEBASE_AUDIT.md` for the current issue register.

---

## 1. Issue Register

| ID | Feature | Severity | Description | Status | Relevant Files | Suspected Cause / Solution |
|---|---|---|---|---|---|---|
| **BUG-01** | Discovery | **CRITICAL** | `LateInitializationError: Field 'discoveryService' has already been initialized` on app start | **FIXED** (commit `bf03589`) | `music_repository.dart` | Declared as `late final`, but reassigned in `_updateProviders()` during `init()`. Changed to `late DiscoveryService`. |
| **BUG-02** | Playback | **CRITICAL** | `Playback failed: (0) Source error`. ExoPlayer fails on local audio playback | **FIXED** | `audio_engine.dart`, `network_security_config.xml` | `just_audio` routes sources with non-null headers through localhost proxy. Local files now pass `headers: null` + `Uri.file`. |
| **BUG-03** | Search | **HIGH** | Local search crashed with `Must return exactly one column (actually returns 3)` | **FIXED** | `music_repository.dart` | Subquery `t.id.isInQuery()` passed 3-column table select instead of `selectOnly(db.lyricsTable)..addColumns([db.lyricsTable.songId])`. |
| **BUG-04** | Streaming | **HIGH** | YouTube streaming failed with unplayable formats or ExoPlayer error | **FIXED** | `ytdlp.py` | YouTube `"android"` client started returning storyboard images (`ext mhtml`). Fixed by using `android_vr`, `tv_embedded`, `android_creator`. |
| **BUG-05** | Migration | **HIGH** | v1->v2 migration crashed parsing `created_at = '2026-01-01'` string | **FIXED** | `app_database.dart` | Drift SQLite stores `DateTime` as unix-epoch integer. Raw SQL string failed parser. Fixed by using typed `PlaylistsCompanion.insert`. |
| **BUG-06** | Playlists | **MEDIUM** | Adding non-downloaded YouTube search result to playlist caused song to vanish | **FIXED** | `music_repository.dart` | Inner join in `playlistSongRows` failed because no `Songs` row existed. Fixed by upserting a stub row (`status: streamable`). |
| **BUG-07** | Search Speed | **MEDIUM** | YouTube search took ~18s for 10 results | **FIXED** | `ytdlp.py` | Switched from full video extraction to `opts["extract_flat"] = "in_playlist"`, reducing latency to ~2s. |
| **DEBT-01** | Downloads | **MEDIUM** | Spotify CSV playlist import is strictly sequential | **TECHNICAL DEBT** | `music_repository.dart`, `MainActivity.kt` | Single-threaded Kotlin executor processes one download at a time. An 800-song import takes several hours. |
| **DEBT-02** | Acoustics | **LOW** | Newly downloaded YouTube tracks lack acoustic features | **KNOWN LIMITATION** | `local_provider.dart`, `tables.dart` | Only pre-seeded CSV songs contain Spotify acoustic vectors (`energy`, `valence`, `tempo`). New downloads have `null` acoustics. |
| **DEBT-03** | Install | **LOW** | `adb install -r -t` fails on Realme devices (`INSTALL_FAILED_VERIFICATION_FAILURE`) | **ENVIRONMENTAL WORKAROUND** | `SESSION.md` | Oppo/Realme OS package verification blocks direct adb install. Workaround: `adb push ... /data/local/tmp/; adb shell pm install -r -t ...`. |
| **DEBT-04** | ADB Daemon | **LOW** | Narzo 70 Pro 5G drops off adb server periodically | **ENVIRONMENTAL WORKAROUND** | `SESSION.md` | Physical USB cable / power saving glitch. Workaround: `adb kill-server; adb start-server`. |

---

## 2. Technical Debt & Fragility Deep-Dive

### 2.1 Python Executors (`MainActivity.kt`) — RESOLVED 2026-11-01
- Interactive calls, downloads and local file work now use separate executor pools with bounded timeouts.
- A download no longer blocks search, streaming extraction, lyrics or tagging. A timed-out call is reported to Dart, and downloads can be cancelled through the Python cancel flag.

### 2.2 Acoustic Feature Cold-Start for New Tracks
- When Spotless imports a Spotify CSV or discovers a song on YouTube, it stores the title, artist, and YouTube ID, but `energy`, `tempo`, `valence`, and `danceability` remain `null`.
- `LocalMetadataProvider` handles this gracefully by falling back to genre overlap or random sampling, but it means new downloads do not contribute to 4D Euclidean distance clustering unless acoustic features are fetched from an external API or extracted via audio analysis (e.g. `aubio` / `librosa`).

### 2.3 `just_audio` play() Deadlock Hazard
- In Dart, `AudioPlayer.play()` is a long-running future that does not complete until the audio pauses or stops.
- If a future maintainer writes `await player.play()` inside a song change callback, crossfade loop, or UI tap handler, the application will hang silently without an error stack.
- **Rule**: Always invoke `unawaited(player.play())` or fire-and-forget in transition code.
