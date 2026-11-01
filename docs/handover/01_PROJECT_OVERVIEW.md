# 01 — Spotless Master Project Overview

> **Document Version**: 1.0.0  
> **Date**: November 1, 2026  
> **Target Audience**: Incoming Lead/Senior Software Engineers & Autonomous AI Coding Agents  

---

## 1. Executive Summary

**Spotless** is an offline-first personal music system for Android. It was conceived by a developer who wanted to break free from Spotify's proprietary ecosystem while retaining the richness of Spotify's metadata, playlist organization, dynamic theming, and synchronized lyrics.

Unlike standard local MP3 players (such as VLC, Poweramp, or Retro Music), Spotless is built around a **rich Spotify-derived SQLite metadata store** and incorporates **embedded YouTube streaming, canonical studio recording discovery, automated ID3 tagging with embedded artwork, synchronized LRC lyrics, and activity-driven session taste modeling**.

---

## 2. Problem Statement & Target User

### 2.1 The Problem
Users who download their music collections locally typically suffer from:
1. **Broken Metadata & Missing Covers**: Downloaded files often lack high-res album covers, correct track numbering, ISRC tags, and acoustic features (tempo, energy, valence).
2. **Missing Lyrics**: Native players rarely integrate synchronized `.lrc` lyrics with interactive tap-to-seek.
3. **Walled Garden Lock-in**: Streaming platforms (Spotify, Apple Music, YouTube Music) do not grant ownership of music files, inject unwanted recommendations based on commercial partnerships, and alter or remove songs from playlists.
4. **Poor Discovery in Offline Players**: Traditional offline music players have zero recommendation intelligence. When a user wants new music similar to what they have been listening to, they must leave the app.
5. **Clock-Biased Recommendation Engines**: Commercial algorithms falsely assume that morning means "acoustic calm" or night means "chill beats", ignoring the user's actual psychological state and continuity of listening.

### 2.2 The Target User
- Power listeners with large local audio libraries (specifically seeded with 864+ curated Spotify tracks).
- Users who value **permanent file ownership** (files stored locally on the device or microSD card).
- Listeners who demand Spotify-like interactive features: synchronized scrolling lyrics, album-art-derived color theming, drag-and-drop playlist reordering, smart shuffle, and intelligent track radio.

---

## 3. Technology Stack

Spotless utilizes a hybrid architecture combining Flutter's cross-platform UI framework with a native Android background service and an embedded Python runtime:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        SPOTLESS RUNTIME STACK                          │
├────────────────────────────────────────────────────────────────────────┤
│ UI & Presentation    │ Flutter 3.44.8 / Dart 3.12.2                    │
│                      │ Material 3 Expressive Design                    │
│                      │ Dynamic theme extraction (palette_generator)    │
├──────────────────────┼─────────────────────────────────────────────────┤
│ State Management     │ Provider 6.1.5+1 (ChangeNotifier architecture)  │
├──────────────────────┼─────────────────────────────────────────────────┤
│ Audio Engine         │ just_audio 0.10.6 + audio_service 0.18.19       │
│                      │ ExoPlayer backend (Android Media3)             │
│                      │ Dual-player audio crossfading (16 volume steps) │
├──────────────────────┼─────────────────────────────────────────────────┤
│ Local Persistence    │ Drift 2.34.3 SQLite ORM (drift_flutter 0.3.1)   │
│                      │ Schema Version: 3 (8 relational tables)         │
│                      │ SharedPreferences 2.5.5 (key-value settings)    │
├──────────────────────┼─────────────────────────────────────────────────┤
│ Native Android Layer │ Kotlin 2.1.0 / AGP 8.13.0 / Gradle 8.13         │
│                      │ AudioServiceActivity foreground service         │
│                      │ MethodChannel ('spotless/ytdlp')                │
├──────────────────────┼─────────────────────────────────────────────────┤
│ Embedded Python      │ Chaquopy 17.0.0 (Python 3.12 runtime)           │
│ Engine               │ yt-dlp 2026.7.4 (audio stream/download engine) │
│                      │ mutagen 1.47.0 (ID3, APIC, MP4 tagging)        │
│                      │ lrclib HTTP client (synced lyrics fetcher)      │
├──────────────────────┼─────────────────────────────────────────────────┤
│ Target Platform      │ Android 7.0+ (minSdk 24, targetSdk 34)         │
│                      │ 64-bit ABIs only: arm64-v8a, x86_64             │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Current Development Status

The codebase is in **Active Post-Specification Polish & Stabilization**. All 14 engineering phases outlined in the project specification have been coded. The application compiles, passes static analysis with 0 errors, passes all 20 automated tests, and runs on physical hardware (verified on Realme Narzo 70 Pro 5G / Android 14).

### 4.1 Feature Implementation Matrix

| Feature | Status | Implementation Details / Limitations |
|---------|--------|---------------------------------------|
| **Local Playback** | **Fully Implemented** | Plays local MP3/M4A/Opus files via `AudioEngine` (`just_audio`). Tested and working on device. |
| **YouTube Streaming** | **Fully Implemented** | Extracts direct audio streams using `yt-dlp` (`android_vr`/`tv_embedded` clients) and streams via ExoPlayer through the loopback proxy. |
| **Dual-Player Crossfade** | **Fully Implemented** | 4-second overlapping fade (`_player` & `_aux`) in `AudioEngine._runCrossfade`. Configurable via Settings. |
| **In-App Downloading** | **Fully Implemented** | Downloads streams using embedded `yt-dlp` to app-private storage (`files/spotless/downloads/`). |
| **Canonical Audio Acquisition** | **Fully Implemented** | Multi-candidate scoring evaluating official audio, artist channel hints, and duration divergence; penalizes live/cover/remix. |
| **Synchronized Lyrics (.lrc)** | **Fully Implemented** | `LrcParser` parses timestamps; `SyncedLyricsView` provides smooth auto-scroll and tap-to-seek. |
| **Plain Lyrics (.txt)** | **Fully Implemented** | Displays unsynchronized lyrics with UTF-8 character support (Telugu, Tamil, Hindi, English). |
| **Automatic Lyrics Fetch** | **Fully Implemented** | Embedded `ytdlp.py` queries `lrclib.net` exact match API with fallback to fuzzy search; prioritizes synced lyrics. |
| **Embedded ID3 Artwork** | **Fully Implemented** | `CoverService` and `mutagen` embed APIC frames into downloaded MP3s and MP4Cover into M4As. |
| **1–10 Rating System** | **Fully Implemented** | Star widget in Now Playing, Track Radio, and Library. Persists immutable events to `RatingEvents`. |
| **Inactivity Session Tracking** | **Fully Implemented** | `SessionManager` enforces 1-hour continuity cutoff; survives process death; zero clock-of-day bias. |
| **Smart Shuffle & Artist Spacing** | **Fully Implemented** | Blends rating bonus, implicit skip penalties, recency decay, and artist diversity spacing. |
| **Dynamic Playlists** | **Fully Implemented** | CRUD playlists in SQLite (`Playlists`, `PlaylistSongs`), drag-and-drop reordering, export to `.m3u`. |
| **Spotify CSV Playlist Import** | **Fully Implemented** | Parses Spotify CSV exports, finds canonical tracks on YouTube, downloads, tags, and creates playlists. |
| **Offline Library Scanner** | **Fully Implemented** | Scans USB-copied folder (`songs.csv`, `sleep.csv`, `no_sleep.csv`, `music/`, `lyrics/`) into SQLite. |
| **Multi-Provider Discovery** | **Fully Implemented** | Combines `LocalMetadataProvider` (Euclidean distance) and optional `LastFmProvider`. Qloo was removed in the 2026-11-01 engineering pass. |
| **Track Radio Modal Sheet** | **Fully Implemented** | Bottom sheet generating dynamic recommendation queue from any seed song. |
| **PixelPlayer M3 Theming** | **Fully Implemented** | Dynamic color extraction from album art (`DynamicThemeProvider`), wavy slider, pill controls. |
| **Background Media Notification** | **Fully Implemented** | `audio_service` media notification with play/pause/prev/next controls and lock screen art. |
| **Sleeping Timer** | **Fully Implemented** | Countdown timer (5/10/15/30/60 min) or "End of current song" pause action. |

### 4.2 Partially Implemented / Environmental Dependencies
- **Last.fm Recommendations**: Fully implemented code-wise in `LastFmProvider`, but requires user to enter their API key in Settings.
- **Qloo Taste Intelligence**: Removed on 2026-11-01; it depended on an API that does not provide the claimed functionality.
- **Local Acoustic Features for New Downloads**: Pre-seeded CSV tracks have acoustic features (`energy`, `valence`, `tempo`, `danceability`). However, newly downloaded YouTube tracks do not automatically calculate acoustic features locally (they rely on metadata/genres or external providers).

### 4.3 Abandoned / Dropped Approaches
1. **Pure Dart YouTube Extractors**: Pure Dart packages (`youtube_explode_dart`) broke frequently due to YouTube's PO-token and JavaScript bot-detection algorithms in 2026. This was abandoned in favor of embedded Python `yt-dlp` via Chaquopy.
2. **Hardcoded Sleep/No Sleep Screens**: The original app had separate hardcoded views for Sleep and No Sleep. This was replaced by generalized database-backed playlists in Schema v2.
3. **Direct File Header Injection for Local Files**: Passing HTTP headers to local files broke ExoPlayer via `just_audio`'s proxy; abandoned in favor of raw `Uri.file(path)` with null headers.

---

## 5. What Makes Spotless Different?

| Conventional Music Player | Spotless |
|---------------------------|----------|
| Reads local directory ID3 tags only. | Imports rich Spotify metadata (ISRC, popularity, acoustic features, genres). |
| Offline only; cannot fetch missing tracks. | Stream-first playback + automated YouTube acquisition via embedded `yt-dlp`. |
| Standard Fisher-Yates random shuffle. | **Smart Shuffle**: Weighted by 1–10 ratings, implicit skips, recency, and artist spacing. |
| Session defined by clock (morning/night). | **Activity-Only Session**: Inactivity threshold ($\ge 1\text{h}$) determines session boundaries. |
| Static lyrics or none. | **Interactive Synced Lyrics**: Tap-to-seek, auto-scroll, prioritized `.lrc` over `.txt`. |
| Single static color theme. | **Dynamic Art Theming**: Dominant colors extracted from current album art drive background and controls. |
| Generic YouTube search. | **Canonical Search**: Custom scoring penalizes live/cover/fan uploads to guarantee studio quality. |

---

## 6. The Intended Final Product Experience

1. **First Launch**: User either points Spotless to an existing local folder containing their music, CSVs, and lyrics, OR imports Spotify playlist CSVs directly in Settings.
2. **Seamless Listening**: Tapping any song immediately plays it without UI lag. If downloaded, it plays from local disk; if streamable, it resolves the YouTube audio stream and plays within ~1.5–2.5 seconds.
3. **Engaging Now Playing**: Full-screen immersive gradient derived from album art. Interactive wavy sinusoidal progress bar. 10-star rating widget allowing instant taste input. Tap lyrics button to view synchronized lyrics and tap any line to jump audio to that second.
4. **Intelligent Flow**: Track Radio lets the user start an endless stream of acoustically and culturally similar songs. Songs rated $\ge 8$ are automatically saved to the local library.
5. **Rock-Solid Background Playback**: Survives app backgrounding, screen off, and navigation. Media notification displays crisp album art and responsive controls.
