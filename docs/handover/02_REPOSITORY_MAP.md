# 02 — Spotless Repository Map

> **Document Version**: 1.0.0  
> **Date**: November 1, 2026  

---

## 1. Annotated Directory Tree

```
D:\Nandhu\spotify\
├── .gitignore                          <- Git ignore rules for root, python, and flutter
├── README.md                           <- High-level specification & quick start guide
├── SESSION.md                          <- Historical session log, device tests, debugging records
├── songs.csv                           <- Seed data: 864 rows mapping files -> title/artist/yt_id
├── sleep.csv                           <- Seed data: 580 rows of Spotify export metadata
├── no_sleep.csv                        <- Seed data: 289 rows of Spotify export metadata
├── download.py                         <- Reference PC script for batch yt-dlp downloading
├── lyrics.py                           <- Reference PC script for lrclib downloading
│
├── docs/                               <- Project documentation
│   └── handover/                       <- Complete Engineering Handover Dossier (YOU ARE HERE)
│
├── lyrics/                             <- Seed lyrics directory (605 .lrc files + 75 .txt files)
│   ├── 0000001.lrc ... 0000869.lrc    <- UTF-8 synchronized timestamped lyrics
│   └── 0000021.txt ... 0000862.txt    <- Plain text unsynchronized lyrics (multilingual)
│
└── app/                                <- Main Flutter Android Application
    ├── pubspec.yaml                    <- Flutter dependencies, SDK version, font declarations
    ├── pubspec.lock                    <- Locked dependency versions
    ├── analysis_options.yaml           <- Dart analyzer rules (flutter_lints ^6.0.0)
    │
    ├── android/                        <- Android native host project
    │   ├── build.gradle.kts            <- Root Gradle build configuration (Kotlin 2.1, AGP 8.13)
    │   ├── settings.gradle.kts         <- Gradle plugin management, Chaquopy maven repo
    │   ├── gradle.properties           <- JVM memory args, AndroidX flags
    │   │
    │   └── app/
    │       ├── build.gradle.kts        <- App-level Gradle: Chaquopy config, SDK 34, ABI filters
    │       │
    │       └── src/main/
    │           ├── AndroidManifest.xml <- Permissions, PyApplication, AudioService declarations
    │           │
    │           ├── kotlin/com/nandhu/spotless/
    │           │   └── MainActivity.kt <- AudioServiceActivity + MethodChannel bridge to Python
    │           │
    │           ├── python/
    │           │   └── ytdlp.py        <- Embedded Python module (yt-dlp, mutagen, lrclib)
    │           │
    │           └── res/
    │               ├── xml/network_security_config.xml <- Cleartext localhost proxy rule
    │               └── mipmap-*/                       <- Launcher icons
    │
    ├── lib/                            <- Flutter application source code
    │   ├── main.dart                   <- App entry point: dependency initialization & root widget
    │   │
    │   ├── core/                       <- Backend & Core Business Logic (DO NOT RANDOMLY REFACTOR)
    │   │   ├── audio/
    │   │   │   └── audio_engine.dart   <- just_audio + audio_service wrapper, dual-player crossfade
    │   │   ├── config/
    │   │   │   └── app_config.dart     <- Central constants, weights, thresholds, decay rates
    │   │   ├── csv/
    │   │   │   └── csv_parser.dart     <- Robust CSV parsing for Spotify exports & songs.csv
    │   │   ├── db/
    │   │   │   ├── tables.dart         <- Drift schema: Songs, Lyrics, Playlists, Sessions, Ratings...
    │   │   │   ├── app_database.dart   <- Drift database class, migrations (v1->v2->v3)
    │   │   │   └── app_database.g.dart <- Generated Drift code (run build_runner if tables change)
    │   │   ├── lyrics/
    │   │   │   └── lrc_parser.dart     <- Parses [mm:ss.xx] timestamps and cleans metadata tags
    │   │   ├── models/
    │   │   │   ├── lyrics.dart         <- Domain model: LyricLine and Lyrics
    │   │   │   └── song_status.dart    <- Enum: analyzing, downloaded, streamable, missing, failed
    │   │   ├── services/
    │   │   │   ├── cover_service.dart  <- Cover art downloading, caching, ID3 APIC embedding
    │   │   │   ├── discovery_service.dart <- Multi-provider candidate ranking, promotion, cleanup
    │   │   │   ├── downloader.dart     <- App-private download coordination via yt-dlp
    │   │   │   ├── feedback_service.dart <- Implicit feedback tracking (skips, replays, completion)
    │   │   │   ├── lastfm_provider.dart  <- Last.fm Web API integration (track.getSimilar)
    │   │   │   ├── library_scanner.dart  <- USB folder scanner (CSV, MP3, LRC matching)
    │   │   │   ├── local_provider.dart   <- Offline acoustic distance (energy, tempo, valence, genre)
    │   │   │   ├── music_repository.dart <- Core application facade; UI talks ONLY to this
    │   │   │   ├── qloo_provider.dart    <- Qloo Taste Intelligence API integration
    │   │   │   ├── rating_service.dart   <- 1-10 explicit rating events & consistency scoring
    │   │   │   ├── recommendation_provider.dart <- Abstract interface & candidate models
    │   │   │   ├── recommender.dart      <- Legacy MetadataRecommender seam
    │   │   │   └── session_manager.dart  <- Inactivity-based session continuity engine
    │   │   ├── state/
    │   │   │   └── player_controller.dart<- Primary ChangeNotifier: queue, smart shuffle, timer
    │   │   └── youtube/
    │   │       └── yt_bridge.dart        <- Dart MethodChannel client for Chaquopy Python
    │   │
    │   └── ui/                         <- User Interface (PixelPlayer-Inspired M3 Expressive)
    │       ├── album_detail_page.dart    <- Collapsing hero header album tracklist
    │       ├── albums_page.dart          <- Grid view of albums with track counts
    │       ├── artist_detail_page.dart   <- Artist discography and top tracks
    │       ├── artists_page.dart         <- List view of artists with track counts
    │       ├── debug_page.dart           <- Developer diagnostics & database inspector
    │       ├── discovery_page.dart       <- Stream-first personalized discovery feed
    │       ├── home_page.dart            <- "Your Mix" hero collage, horizontal carousels
    │       ├── home_shell.dart           <- 3-tab navigation bar (Home, Search, Library)
    │       ├── library_page.dart         <- 4-tab library (Songs, Albums, Artists, Playlists)
    │       ├── liked_songs_page.dart     <- List of songs marked likedAt / rated >= 8
    │       ├── lyrics_page.dart          <- Full-screen immersive synced lyrics
    │       ├── now_playing_page.dart     <- Album art, wavy seekbar, 10-star rating, pill controls
    │       ├── playlist_page.dart        <- Legacy playlist view
    │       ├── playlist_songs_page.dart  <- Reorderable playlist tracks with drag handles
    │       ├── playlists_page.dart       <- Playlist management (create, rename, delete, export)
    │       ├── search_page.dart          <- Dual-mode search: Local SQLite full-text & YouTube
    │       ├── settings_page.dart        <- Library path, Spotify CSV import, crossfade, API keys
    │       │
    │       ├── theme/                    <- Design System & Dynamic Theming
    │       │   ├── dynamic_theme_provider.dart <- PaletteGenerator color extraction from art
    │       │   ├── spotless_colors.dart        <- Static color tokens, surface alphas, gradients
    │       │   ├── spotless_theme.dart         <- ThemeData factory for M3 dark theme
    │       │   └── spotless_typography.dart    <- Typography scale definitions
    │       │
    │       └── widgets/                  <- Reusable UI Components
    │           ├── album_art.dart              <- Multi-source image loader (file, url, fallback)
    │           ├── gradient_top_bar.dart       <- Ambient header with blur and icon actions
    │           ├── mini_player.dart            <- Frosted glass persistent floating player pill
    │           ├── playlist_picker.dart        <- Bottom sheet for adding tracks to playlists
    │           ├── rating_widget.dart          <- Interactive 10-star rating bar with live feedback
    │           ├── rounded_control_button.dart <- PixelPlayer pill-shaped control buttons
    │           ├── section_header.dart         <- Section title widget with optional action button
    │           ├── similar_tracks_sheet.dart   <- Track Radio modal bottom sheet
    │           ├── slidable_song_tile.dart     <- Swipe-to-download / swipe-to-playlist wrapper
    │           ├── song_card.dart              <- Vertical card with artwork for carousels
    │           ├── song_tile.dart              <- Standard library track tile with 3-dot menu
    │           ├── status_badge.dart           <- Streamable, downloaded, missing badge chip
    │           ├── synced_lyrics_view.dart     <- Auto-scrolling lyrics list with tap-to-seek
    │           └── wavy_slider.dart            <- Sinusoidal wave seek bar widget
    │
    └── test/                           <- Automated Unit & Integration Tests
        ├── discovery_test.dart         <- Tests acoustic similarity, radio queue, promotion
        ├── session_test.dart           <- Tests Specification §51 Scenarios 1-8, ratings, LRC
        └── shuffle_test.dart           <- Tests normal shuffle preservation & artist spacing
```

---

## 2. Component Criticality & Modification Safety Analysis

| Subsystem / Directory | Criticality | Safety to Modify Independently | Dependencies & Coupling | Notes |
|-----------------------|-------------|--------------------------------|-------------------------|-------|
| `lib/core/services/music_repository.dart` | **CRITICAL** | **LOW (Do not edit carelessly)** | Relied upon by every screen, `PlayerController`, and `DynamicThemeProvider`. | God-facade coordinating all backend services. Changes here propagate everywhere. |
| `lib/core/audio/audio_engine.dart` | **CRITICAL** | **VERY LOW** | Coupled with `just_audio`, `audio_service`, ExoPlayer, and Android localhost proxy. | Timing-sensitive. Dual players (`_player` & `_aux`) must not deadlock. |
| `lib/core/state/player_controller.dart` | **HIGH** | **MEDIUM** | Consumes `MusicRepository` and `AudioEngine`; observed by entire UI. | Holds queue and shuffle order. State changes notify all listeners. |
| `lib/core/db/` | **CRITICAL** | **LOW** | All data services query tables. Requires schema migrations on modification. | If editing `tables.dart`, MUST increment `schemaVersion` in `app_database.dart` and run `build_runner`. |
| `android/.../ytdlp.py` | **HIGH** | **MEDIUM** | Invoked via Kotlin `MainActivity.kt` and `yt_bridge.dart`. | Pure Python. Must return valid JSON strings. Beware of YouTube format changes. |
| `android/.../MainActivity.kt` | **HIGH** | **MEDIUM** | Manages `spotless/ytdlp` MethodChannel and single-thread Python executor. | Extends `AudioServiceActivity`. Must handle Python timeouts gracefully. |
| `lib/ui/widgets/` | **MEDIUM** | **HIGH (Safe to restyle)** | Independent presentation widgets. | High safety for UI changes, provided callbacks remain intact. |
| `lib/ui/theme/` | **MEDIUM** | **HIGH (Safe to restyle)** | Consumed by `SpotlessApp` and pages for color tokens. | Changing colors or typography does not break audio or business logic. |
| `lib/core/lyrics/lrc_parser.dart` | **LOW** | **HIGH** | Independent parser. Pure Dart string processing. | Covered by unit tests in `session_test.dart`. |
| `test/` | **HIGH** | **HIGH** | Validates core specification requirements. | Run `flutter test` after ANY backend or service modification. |
