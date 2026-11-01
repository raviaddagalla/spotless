# 00 — Start Here: Spotless Engineering Handover Entry Point

> **Document Version**: 1.0.0  
> **Date of Audit & Handover**: November 1, 2026  
> **Repository**: [raviaddagalla/spotless](https://github.com/raviaddagalla/spotless)  
> **Primary Technology**: Flutter (Dart ^3.12.2) + Chaquopy (Embedded Python 3.12 / yt-dlp / Mutagen) + Drift SQLite (Schema v3) + just_audio / audio_service  

---

## 1. What Is Spotless?

Spotless is a **personal, offline-first, Spotify-like music player for Android**. It was created to replace proprietary streaming apps by providing a local, private, beautifully designed audio player that plays the user's permanent local music library while augmenting it with:

1. **YouTube Streaming & Canonical Audio Acquisition**: Streams un-downloaded tracks on demand and downloads official studio recordings using embedded `yt-dlp` and `mutagen` via Chaquopy.
2. **Stream-First Music Discovery & Track Radio**: Recommends new music based on multi-source recommendation providers (Local Acoustic Features, optional Last.fm) that users can listen to before deciding to promote/download into their permanent library.
3. **Inactivity-Based Session Continuity**: Strict activity-driven listening session tracking with zero clock/time-of-day bias.
4. **1–10 Rating System with Event History**: Rating events are stored immutably to evaluate taste consistency across distinct sessions.
5. **Interactive Synchronized Lyrics**: Formats `.lrc` lyrics with live position tracking, tap-to-seek, and automatic center-scrolling.
6. **Smart Shuffle & Artist Diversity Spacing**: Queue reordering based on implicit and explicit feedback, enforcing spacing so consecutive tracks do not repeat artists.
7. **PixelPlayer-Inspired Modern Expressive UI**: Dynamic color extraction from album art, wavy seek bar, collapsing hero headers, and frosted glass mini-player.

---

## 2. Current State of the Codebase

- **Branch**: `main`
- **Git State**: Engineering fixes committed and pushed to `origin/main`. See [16_ENGINEERING_PASS_2026-11-01.md](16_ENGINEERING_PASS_2026-11-01.md) and `docs/development/FINAL_HANDOVER.md` for hashes and status.
- **Static Analysis**: `flutter analyze` passes with **0 errors, 0 warnings, 0 issues**.
- **Automated Tests**: **27 / 27 tests pass** (session, shuffle, discovery, library scanner, download queue).
- **Release APK**: Built at `artifacts/android/Spotless-0.1.0-release.apk` (87,834,851 B, arm64-v8a + x86_64) and signed with the local release key (`app/android/spotless-release.jks`, gitignored). The debug-signed fallback is not distributable.
- **On-device verification**: BLOCKED on this machine (no device or AVD).

---

## 3. Critical Warnings for Incoming Engineering Agents

> [!CAUTION]
> **1. DO NOT TOUCH `AudioEngine._sourceFor()` URL RESOLUTION**  
> In `app/lib/core/audio/audio_engine.dart`, local audio files MUST have `headers: null` passed to `AudioSource.uri(Uri.file(path))`. `just_audio` routes ANY `UriAudioSource` with a non-null headers map (even `{}`) through its internal localhost HTTP proxy server (`127.0.0.1:<port>`). Local filesystem paths passed with headers trigger cleartext HTTP to localhost, which ExoPlayer blocks on Android 9+ (API 28+), causing fatal playback crash `"Source error (0)"`. Remote YouTube streams use extracted HTTP headers and go through the proxy, permitted by `android/app/src/main/res/xml/network_security_config.xml`.

> [!WARNING]
> **2. NEVER AWAIT `_player.play()` INSIDE TRANSITIONS OR CROSSFADES**  
> `AudioPlayer.play()` in `just_audio` returns a `Future` that **only resolves when playback pauses, completes, or stops**. Awaiting `play()` during song transitions or crossfade volume ramps will deadlock the execution queue and freeze playback. Always use `unawaited(player.play())`.

> [!WARNING]
> **3. DO NOT HARDCODE PLAYLIST LOGIC BASED ON NAMES**  
> In early versions of Spotless, `sleep` and `no_sleep` were separate CSV columns and hardcoded screens. In Schema v2/v3, **all playlists are dynamic and database-backed** (`Playlists` and `PlaylistSongs` tables). Do not add special-cased conditionals for `"sleep"` or `"no_sleep"`.

> [!IMPORTANT]
> **4. CHAQUOPY PYTHON RUNTIME CONSTRAINTS**  
> The Android build embeds Python 3.12 via Chaquopy 17.0.0. The build host requires Python 3.12; set `CHAQUOPY_PYTHON` to its absolute path or have `python` on `PATH`. Supported ABIs are restricted to `arm64-v8a` and `x86_64` (32-bit `armeabi-v7a` is intentionally excluded because Python 3.12+ 64-bit packages do not support it). Do not add `--split-per-abi` to Flutter build commands as it conflicts with Chaquopy's NDK configuration.

> [!IMPORTANT]
> **5. SESSION RULES ARE SACROSANCT**  
> Sessions represent continuous listening activity. A gap of $\ge 1\text{ hour}$ ends a session. Closing the app or backgrounding does NOT end a session if resumed within 1 hour. Never introduce morning/afternoon/evening clock heuristics.

---

## 4. Recommended Reading Order

To understand this system with minimal wasted exploration, read the dossier documents in this order:

| Order | Document | Purpose |
|-------|----------|---------|
| 1 | [01_PROJECT_OVERVIEW.md](file:///d:/Nandhu/spotify/docs/handover/01_PROJECT_OVERVIEW.md) | High-level product intent, problem statement, feature completeness matrix |
| 2 | [03_ARCHITECTURE.md](file:///d:/Nandhu/spotify/docs/handover/03_ARCHITECTURE.md) | System design, execution flow, playback engine, Mermaid architecture diagrams |
| 3 | [05_DATABASE_AND_DATA_MODELS.md](file:///d:/Nandhu/spotify/docs/handover/05_DATABASE_AND_DATA_MODELS.md) | Drift SQLite Schema v3, tables, entities, migration paths |
| 4 | [04_FEATURES.md](file:///d:/Nandhu/spotify/docs/handover/04_FEATURES.md) | Deep technical breakdown of all 9 core subsystems (audio, yt-dlp, discovery, sessions, etc.) |
| 5 | [02_REPOSITORY_MAP.md](file:///d:/Nandhu/spotify/docs/handover/02_REPOSITORY_MAP.md) | Annotated directory tree and architectural criticality index |
| 6 | [06_EXTERNAL_INTEGRATIONS.md](file:///d:/Nandhu/spotify/docs/handover/06_EXTERNAL_INTEGRATIONS.md) | Chaquopy, yt-dlp, lrclib, Last.fm, ExoPlayer proxy |
| 7 | [07_UI_AND_NAVIGATION.md](file:///d:/Nandhu/spotify/docs/handover/07_UI_AND_NAVIGATION.md) | Screen hierarchy, PixelPlayer M3 design system, state consumption |
| 8 | [08_ANDROID_AND_BUILD.md](file:///d:/Nandhu/spotify/docs/handover/08_ANDROID_AND_BUILD.md) | Gradle, Chaquopy, Kotlin MethodChannels, Android permissions, ADB runbook |
| 9 | [09_DEPENDENCIES.md](file:///d:/Nandhu/spotify/docs/handover/09_DEPENDENCIES.md) | Complete pubspec & pip inventory with override explanations |
| 10 | [10_BUGS_AND_TECHNICAL_DEBT.md](file:///d:/Nandhu/spotify/docs/handover/10_BUGS_AND_TECHNICAL_DEBT.md) | Verified issues register, architectural debt, gotchas |
| 11 | [11_TESTING_AND_VALIDATION.md](file:///d:/Nandhu/spotify/docs/handover/11_TESTING_AND_VALIDATION.md) | Automated tests, regression checklist, manual device verification |
| 12 | [12_DEVELOPMENT_WORKFLOW.md](file:///d:/Nandhu/spotify/docs/handover/12_DEVELOPMENT_WORKFLOW.md) | Git conventions, verified build commands, device quirks |
| 13 | [13_PRODUCT_REQUIREMENTS_AND_DECISIONS.md](file:///d:/Nandhu/spotify/docs/handover/13_PRODUCT_REQUIREMENTS_AND_DECISIONS.md) | The "Why" behind track identity, lyrics, sessions, ratings, and Kotlin UI evaluation |
| 14 | [14_NEXT_AGENT_ROADMAP.md](file:///d:/Nandhu/spotify/docs/handover/14_NEXT_AGENT_ROADMAP.md) | Prioritized P0–P3 roadmap, critical questions to resolve |
| 15 | [15_FILE_REFERENCE_INDEX.md](file:///d:/Nandhu/spotify/docs/handover/15_FILE_REFERENCE_INDEX.md) | Searchable symbol index: classes, files, line numbers, responsibilities |
| 16 | [16_ENGINEERING_PASS_2026-11-01.md](file:///d:/Nandhu/spotify/docs/handover/16_ENGINEERING_PASS_2026-11-01.md) | What changed after the dossier: fixes, tests, APKs and corrected claims |
| 17 | [HANDOVER_MANIFEST.md](file:///d:/Nandhu/spotify/docs/handover/HANDOVER_MANIFEST.md) | Audit scope, inspected files, completeness verification |

---

## 5. First 30 Minutes: What the New Agent Should Do

1. **Verify Toolchains**:
   - Flutter SDK: `C:\Users\aravi\flutter\bin\flutter.bat --version` (Flutter 3.44.8 / Dart 3.12.2)
   - Python: `C:\Users\aravi\AppData\Local\Programs\Python\Python312\python.exe --version` (Python 3.12.x)
   - Android SDK: `C:\Users\aravi\AppData\Local\Android\Sdk`
2. **Run Analysis & Test Suite**:
   ```powershell
   cd d:\Nandhu\spotify\app
   & C:\Users\aravi\flutter\bin\flutter.bat analyze
   & C:\Users\aravi\flutter\bin\flutter.bat test
   ```
   Both must pass cleanly.
3. **Inspect the Architecture Facade**:
   Open [app/lib/core/services/music_repository.dart](file:///d:/Nandhu/spotify/app/lib/core/services/music_repository.dart). This is the single facade that coordinates the database, audio engine, scanner, downloader, covers, and discovery services.
4. **Inspect the State Controller**:
   Open [app/lib/core/state/player_controller.dart](file:///d:/Nandhu/spotify/app/lib/core/state/player_controller.dart). Understand how queue changes, shuffle reordering, and playback actions bridge between UI and `AudioEngine`.
5. **Inspect the Python Bridge**:
   Open [app/lib/core/youtube/yt_bridge.dart](file:///d:/Nandhu/spotify/app/lib/core/youtube/yt_bridge.dart), [app/android/app/src/main/kotlin/com/nandhu/spotless/MainActivity.kt](file:///d:/Nandhu/spotify/app/android/app/src/main/kotlin/com/nandhu/spotless/MainActivity.kt), and [app/android/app/src/main/python/ytdlp.py](file:///d:/Nandhu/spotify/app/android/app/src/main/python/ytdlp.py) to see how YouTube searches, stream extractions, and file downloads execute.
