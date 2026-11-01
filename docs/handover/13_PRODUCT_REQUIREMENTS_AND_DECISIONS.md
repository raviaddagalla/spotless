# 13 — Product Requirements, Decisions, and Migration Context

> **Document Version**: 1.0.0  
> **Date**: November 1, 2026  

---

## 1. Core Product Decisions and Intent

### 1.1 Track Identity & Canonical Matching
- **Non-Naive Matching**: In traditional players, tracks with the same artist and title are treated as identical. Spotless explicitly avoids this. Songs with identical names can have distinct recordings (remasters, acoustic cuts, live versions, remixes).
- **Canonical Recording Acquisition**: When downloading from YouTube:
  - YouTube search queries strictly favor **official studio recordings** over live performances, concerts, covers, remixes, karaoke, sped-up/nightcore versions, and fan uploads.
  - Duration matching is enforced: candidate videos diverging by $>30\text{ seconds}$ from Spotify's recorded duration receive heavy penalties ($-25$ to $-40$).
  - Official channels (`vevo`, `records`, `official`) receive strong preference score bonuses ($+10$ to $+15$).
- **Metadata Tagging**: All downloaded files must receive proper ID3v2.4 / MP4 tags (`title`, `artist`, `album`) and embedded artwork before being added to the active library.

### 1.2 Synchronized Lyrics Intent
- **Exact Recording Alignment**: Lyrics must correspond to the exact studio recording played. Arbitrary manual millisecond offset sliders are prohibited because they merely mask wrong recording matches.
- **Priority**: Synchronized `.lrc` lyrics are strictly prioritized over plain text `.txt`.
- **Interactivity**: Users must be able to tap any lyric line to jump audio playback to that exact second (`tap-to-seek`).
- **Multilingual Support**: Supports non-Latin scripts (Telugu, Tamil, Devanagari, Japanese, Korean) encoded in UTF-8 without font rendering issues.

### 1.3 Shuffle Modes: Normal vs. Smart Shuffle
The product explicitly distinguishes between two shuffle modes:
1. **Normal Shuffle**:
   - Standard random permutation of queue indices.
   - Preserves the currently playing song at index 0.
   - Contains all queue items exactly once without duplicates or omissions.
2. **Smart Shuffle**:
   - Re-weights the queue dynamically using:
     - **Explicit Ratings**: Songs rated 8–10 receive bonus $+0.5 \times (\text{rating} - 7)$; songs rated $\le 4$ receive penalties.
     - **Implicit Skips**: Early skips ($<20\%$ completion) penalize songs; full completions boost them.
     - **Recency Decay**: Songs played within the last 12 hours receive penalty $-0.5$; within 48 hours receive $-0.2$.
     - **Liked Bonus**: Songs marked liked receive $+0.3$.
     - **Artist Diversity Spacing**: Enforces spacing so consecutive tracks never share the same artist.

### 1.4 Playlists: Decoupled & Database-Backed
- The early legacy concept of hardcoded `Sleep` and `No Sleep` modes has been fully retired.
- All playlists are standard database rows in `Playlists` and `PlaylistSongs`.
- Any playlist can be renamed, reordered via drag-and-drop, deleted, or exported to `.m3u`.
- No application logic may branch on playlist names.

### 1.5 The Inactivity Session Model (Zero Time-of-Day Bias)
- **The Philosophy**: Human emotional taste does not neatly divide into 9:00 AM "morning coffee" and 10:00 PM "sleep". Listening state is defined by **continuity of engagement**.
- **Rules**:
  1. A session begins upon the first meaningful activity (playback start, seek, rate, skip).
  2. Continuing to listen, pause, or resume within $<1\text{ hour}$ remains inside the same session.
  3. Pausing playback or closing the app for $\ge 1\text{ hour}$ seals the previous session (`state = 'completed'`) and causes the next activity to create a new session.
  4. App backgrounding, activity recreation, or process restart must NOT terminate a session if resumed within 1 hour.
  5. The system must maintain **current-session taste** (immediate mood) separately from **long-term taste** (cross-session consistency).

---

## 2. UI Reference & Migration Context: PixelPlayer vs. Spotless

The developer evaluated modernizing Spotless's user interface using patterns from **PixelPlayer**:
- **Reference Application**: [PixelPlayerHQ/PixelPlayer](https://github.com/PixelPlayerHQ/PixelPlayer) (Native Android Kotlin / Jetpack Compose).
- **Target Application**: [raviaddagalla/spotless](https://github.com/raviaddagalla/spotless) (Flutter Android).

### 2.1 The Architectural Stance
> [!IMPORTANT]
> **PixelPlayer is a visual reference for UI design, NOT a replacement for Spotless.**  
> Spotless's backend—Drift SQLite Schema v3, Chaquopy embedded yt-dlp, LRCLIB lyrics synchronization, dual-player crossfade, multi-provider discovery, and inactivity session modeling—is vastly more capable than PixelPlayer's local media-store scanner. Under no circumstances should Spotless's backend logic be broken or discarded in pursuit of a visual redesign.

### 2.2 Recreating in Flutter vs. Migrating to Native Kotlin
The developer considered two paths:

#### Option A: Recreate PixelPlayer Design Language in Flutter (CHOSEN & IMPLEMENTED in `cbd2a30`)
- **Feasibility**: High. Flutter's widget tree effortlessly replicates Material 3 Expressive shapes, sinusoidal curves (`WavySlider`), frosted glass (`BackdropFilter`), and dynamic theme generation (`PaletteGenerator`).
- **Outcome**: Successfully merged in commit `cbd2a30`. Spotless now features the exact visual language of PixelPlayer (3-tab shell, ambient gradients, wavy seek bars, pill controls, tabbed library) while preserving 100% of the Flutter backend, Drift database, and test suites.

#### Option B: Full Rewrite to Native Kotlin / Jetpack Compose (Evaluated but NOT Recommended)
- **Feasibility Assessment**:
  - **Effort**: Extremely high (~120–160 engineering hours).
  - **Risks**:
    - Complete rewrite of Drift SQLite schema into Android Room ORM.
    - Porting complex dual-player crossfade logic and localhost proxy handling from `just_audio` to raw Android Media3 / ExoPlayer.
    - Rewriting `YtBridge` and Chaquopy method channels into direct Kotlin Chaquopy calls.
    - Porting the entire test suite (20 automated tests) to JUnit 5 / Robolectric.
  - **Gain**: Marginal (slightly smaller native APK size ~45MB vs 59MB).
  - **Conclusion**: A full rewrite to Kotlin is unjustified given that Flutter has already achieved the target UI fidelity, 60fps animations, and zero-warning analyzer status.

### 2.3 Licensing & Code Reuse Warnings
- PixelPlayer is an open-source project hosted on GitHub.
- Any engineer inspecting PixelPlayer's Kotlin source code must verify its license (e.g. GPL-3.0 vs. Apache 2.0 vs. MIT) before copying code or assets.
- Code under copyleft licenses (GPL/AGPL) cannot be copied directly into proprietary or differently-licensed codebases without legal implications. Recreating visual concepts from scratch in Flutter avoids all copyright and licensing conflicts.
