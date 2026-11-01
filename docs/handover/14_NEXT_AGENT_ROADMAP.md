# 14 — Prioritized Next Agent Roadmap & Exploration Guide

> **Document Version**: 1.0.0  
> **Date**: November 1, 2026  

---

## 1. Prioritized Work Roadmap

### P0: Critical (Must Understand Before Modifying Code)
| Objective | Status | Relevant Files | Dependencies | Risks | Validation Method |
|---|---|---|---|---|---|
| **P0.1: Verify Startup Crash Fix** | **COMPLETED** (Commit `bf03589`) | `music_repository.dart` | `DiscoveryService`, `SharedPreferences` | Regressing to `LateInitializationError` if reassigned improperly. | Launch debug and release APKs; confirm zero startup errors. |
| **P0.2: Understand Proxy Routing** | **DOCUMENTED** | `audio_engine.dart`, `network_security_config.xml` | `just_audio`, ExoPlayer | Passing headers to local audio files breaks playback completely (`Source error 0`). | Verify `_sourceFor` passes `headers: null` for all local `Uri.file` sources. |
| **P0.3: Understand Schema Migrations** | **DOCUMENTED** | `tables.dart`, `app_database.dart` | Drift SQLite v3 | Altering columns without incrementing schema version crashes existing installs. | Run `flutter test test/session_test.dart` to verify in-memory migration integrity. |

---

### P1: High Priority (Reliability & Architecture Hardening)
| Objective | Status | Relevant Files | Dependencies | Risks | Validation Method |
|---|---|---|---|---|---|
| **P1.1: Decouple Python Executor Threads** | **PENDING** | `MainActivity.kt` | Chaquopy, Kotlin Concurrency | Heavy CSV downloads block on-demand YouTube streaming queries. | Test searching YouTube while an import download is active in the background. |
| **P1.2: Validate Stream Expiry Auto-Recovery** | **IMPLEMENTED, NEEDS DEVICE CONFIRMATION** | `audio_engine.dart` | `just_audio`, `ytdlp.py` | Expired `googlevideo.com` streams might stop queue auto-advance if error handling drops. | Simulate a 403 on a stream URL; verify engine re-resolves and continues playing. |
| **P1.3: Verification of v1->v2 Migration on Device** | **PENDING PHYSICAL DEVICE TEST** | `app_database.dart` | Drift migration | Existing users upgrading from old pre-release builds could see playlist schema errors. | Push v1 database with text dates, launch app, check Playlists tab. |

---

### P2: Medium Priority (Feature Polish & Technical Debt)
| Objective | Status | Relevant Files | Dependencies | Risks | Validation Method |
|---|---|---|---|---|---|
| **P2.1: Acoustic Feature Extraction for Downloads** | **PLANNED** | `downloader.dart`, `local_provider.dart` | Python / Aubio / Spotify API | New downloads have `null` acoustic vectors and do not cluster in 4D space. | Run `discoverSimilarTo` seeded with a newly downloaded track. |
| **P2.2: Parallel Download Worker Pool** | **PLANNED** | `music_repository.dart`, `MainActivity.kt` | Android CPU / Network | Spotify CSV imports of 800+ songs take hours sequentially. | Measure import duration for a 50-track test playlist. |
| **P2.3: Audio Notification Progress Bar** | **POLISH** | `audio_engine.dart` | `audio_service` | Media notification scrubber might be coarse on older Android versions. | Verify notification scrubber accuracy on Android 13/14 lock screen. |

---

### P3: Future Product Direction
| Objective | Status | Relevant Files | Dependencies | Risks | Validation Method |
|---|---|---|---|---|---|
| **P3.1: Collaborative Playlist Sharing** | **FUTURE** | `playlists_page.dart` | Local Wi-Fi / WebRTC | Network complexity without cloud servers. | P2P playlist syncing between two phones on same Wi-Fi. |
| **P3.2: ReplayGain & Volume Normalization** | **FUTURE** | `audio_engine.dart` | ExoPlayer audio processors | Volume discrepancies between quiet local rips and loud YouTube audio. | Measure perceived loudness across mixed local and stream queues. |
| **P3.3: Waveform Visualizer for Now Playing** | **FUTURE** | `wavy_slider.dart` | FFT audio analysis | CPU battery drain on low-end devices. | Profile GPU and battery consumption during playback. |

---

## 2. Questions the Incoming Agent Should Answer Before Modifying Code

Before you commit any new code to this repository, answer these questions by independently inspecting the referenced files:

1. **Is there more than one playback engine in the codebase?**
   - *Inspection Target*: [app/lib/core/audio/audio_engine.dart](file:///d:/Nandhu/spotify/app/lib/core/audio/audio_engine.dart).
   - *Answer to verify*: There is exactly one engine (`AudioEngine`), but it instantiates **two** `AudioPlayer` objects (`_player` and `_aux`) to execute gapless crossfading.
2. **Who owns the authoritative playback state?**
   - *Inspection Target*: [app/lib/core/state/player_controller.dart](file:///d:/Nandhu/spotify/app/lib/core/state/player_controller.dart).
   - *Answer to verify*: `PlayerController` owns the queue order, shuffle permutation, and current song index. `AudioEngine` owns hardware ExoPlayer streams and position ticking.
3. **Can playback survive process death and activity destruction?**
   - *Inspection Target*: [app/android/app/src/main/AndroidManifest.xml](file:///d:/Nandhu/spotify/app/android/app/src/main/AndroidManifest.xml) and [app/lib/core/audio/audio_engine.dart](file:///d:/Nandhu/spotify/app/lib/core/audio/audio_engine.dart).
   - *Answer to verify*: Yes. `com.ryanheise.audioservice.AudioService` is declared as an Android Foreground Service with type `mediaPlayback`.
4. **Are downloaded files and metadata persisted across restarts?**
   - *Inspection Target*: [app/lib/core/db/app_database.dart](file:///d:/Nandhu/spotify/app/lib/core/db/app_database.dart) and [app/lib/core/services/downloader.dart](file:///d:/Nandhu/spotify/app/lib/core/services/downloader.dart).
   - *Answer to verify*: Yes. Audio files land in `files/spotless/downloads/` and metadata is committed to the `Songs` table in `spotless.sqlite`.
5. **How is a track uniquely identified across the system?**
   - *Inspection Target*: [app/lib/core/db/tables.dart](file:///d:/Nandhu/spotify/app/lib/core/db/tables.dart).
   - *Answer to verify*: By `Songs.id`. For pre-seeded songs, it is `"0000001"`; for Spotify imports, `"spotify:track:..."` or `"imp:<plId>:<i>"`; for YouTube tracks, `"yt:<videoId>"`.
6. **Are lyrics linked to an exact recording or merely matched by title/artist?**
   - *Inspection Target*: [app/android/app/src/main/python/ytdlp.py](file:///d:/Nandhu/spotify/app/android/app/src/main/python/ytdlp.py): `fetch_lyrics()` and [app/lib/core/services/music_repository.dart](file:///d:/Nandhu/spotify/app/lib/core/services/music_repository.dart).
   - *Answer to verify*: Linked by `songId` in SQLite. Fetched using `track_name`, `artist_name`, `album_name`, and exact `duration` to prevent live/cover desync.
7. **Is the recommendation engine functional offline?**
   - *Inspection Target*: [app/lib/core/services/local_provider.dart](file:///d:/Nandhu/spotify/app/lib/core/services/local_provider.dart).
   - *Answer to verify*: Yes. `LocalMetadataProvider` operates 100% offline using 4D Euclidean distance on acoustic features stored in SQLite.
8. **Is the session boundary correctly implemented without clock time-of-day bias?**
   - *Inspection Target*: [app/lib/core/services/session_manager.dart](file:///d:/Nandhu/spotify/app/lib/core/services/session_manager.dart) and [app/test/session_test.dart](file:///d:/Nandhu/spotify/app/test/session_test.dart).
   - *Answer to verify*: Yes. Strict 1-hour inactivity threshold; zero clock-of-day inference. Validated by 8 automated test scenarios.
9. **What parts of the UI can be redesigned without touching business logic?**
   - *Inspection Target*: [app/lib/ui/](file:///d:/Nandhu/spotify/app/lib/ui/).
   - *Answer to verify*: All files in `app/lib/ui/` and `app/lib/ui/widgets/` consume `PlayerController` and `MusicRepository` via clean interfaces. Any widget or screen can be restyled as long as the controller methods are invoked.
10. **What would break if you accidentally altered `_sourceFor` in `AudioEngine`?**
    - *Answer to verify*: All local MP3 playback would immediately throw ExoPlayer cleartext localhost proxy errors.
