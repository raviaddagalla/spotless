# Spotless — Personal Offline-First Android Music Player

Spotless is a personal Spotify-like music player for Android built with Flutter, Drift SQLite ORM, `just_audio`, and an embedded Chaquopy Python engine (`yt-dlp` and `mutagen`).

It is designed to remain strictly **offline-first** for the user's permanent local library, while providing YouTube streaming, stream-first discovery, canonical audio acquisition, synchronized lyrics with tap-to-seek, and activity-based recommendation modeling.

---

## Key Highlights & Core Philosophy

### 1. Inactivity-Based Session Continuity (Zero Time-of-Day Bias)
* **Activity Continuity**: A session represents a continuous period of active music interaction.
* **1-Hour Inactivity Cutoff**: Continuous listening or interruptions under 1 hour preserve the session; gaps $\ge 1\text{ hour}$ seal the session and generate a new one upon the next interaction.
* **No Clock Time-of-Day Modeling**: The system never infers "morning", "night", or "weekday" preferences from the clock. Temporary listening desires are tracked separately from long-term taste without clock bias.

### 2. 10-Point Rating System & History Preservation
* **Explicit 1–10 Ratings**: Interactive 10-star rating widget in the Now Playing screen, Track Radio sheet, and library context menus.
* **Immutable Event History**: Every rating event is stored with its track ID, session ID, rating, and timestamp. Past ratings are never overwritten.
* **Cross-Session Consistency**: Repeated high ratings across independent sessions increase long-term preference; volatile ratings indicate temporary interest.

### 3. Stream-First Music Discovery & Track Radio
* **Stream First**: Recommended tracks stream directly before downloading.
* **Track Radio**: 1-tap modal bottom sheet generating a radio queue for any seed track using provider and acoustic matching.
* **Download Promotion**: Tracks with strong positive evidence (explicit rating $\ge 8$) are automatically promoted and downloaded to the permanent library.
* **Automated Cache Maintenance**: Unpromoted candidates older than 30 days are automatically cleaned up on startup.

### 4. Decoupled Recommendation Engine
* **Multi-Component Scoring**:
  $$\text{finalScore} = \text{longTermScore} + \text{currentSessionScore} + \text{externalScore} + \text{noveltyScore} - \text{repetitionPenalty} - \text{negativeFeedbackPenalty}$$
* **Multiple Providers**:
  - **Last.fm Provider**: External track and artist similarity web services.
  - **Qloo Provider**: Cultural AI taste recommendations.
  - **Local Metadata Provider**: Guaranteed offline fallback computing Euclidean acoustic distance using Spotify audio features (`energy`, `tempo`, `valence`, `danceability`, and genre overlaps).

### 5. Canonical YouTube Audio Acquisition
* **Canonical Search Scoring**: Multi-candidate scoring evaluating official audio, artist/label channels (`vevo`, `records`), and duration divergence while penalizing `live`, `cover`, `remix`, `karaoke`, `instrumental`, `nightcore`, and fan uploads.
* **Duration-Aware Lyrics Matching**: Matches LRC lyrics against exact recording length and album tags.

### 6. Interactive Synchronized Lyrics
* **Bug Fix**: Synced lyrics (`.lrc`) are strictly prioritized over plain unsynchronized lyrics.
* **Tap-to-Seek**: Tapping any timestamped lyric line immediately seeks playback to that exact second with seamless scrolling and progress bar synchronization.

### 7. Smart Shuffle & Artist Diversity Spacing
* **Smart Shuffle**: Scores queue items using rating history, session affinity, implicit duration-weighted skips, and recency penalties.
* **Artist Diversity Spacing**: Enforces spacing so consecutive songs never share the same artist.
* **Live Indicator**: Queue sheet displays an active status badge when Smart Shuffle is enabled.

### 8. Decoupled Dynamic Playlists
* **No Hardcoding**: Fully removed hardcoded `Sleep` and `No Sleep` concepts; all playlists are database-backed.
* **Reorderable Drag & Drop**: Persistent drag-and-drop track reordering, Play All, and Shuffle Play.

---

## Architecture Overview

```
Spotless Application
│
├── lib/core/
│   ├── audio/           # just_audio & audio_service integration (gapless & crossfade)
│   ├── config/          # Centralized AppConfig (weights, decay constants, thresholds)
│   ├── db/              # Drift SQLite ORM (Schema v3: Sessions, Ratings, Playback, Discovery)
│   ├── lyrics/          # LRC parser & timestamp synchronization
│   ├── models/          # SongStatus, Lyrics, and domain models
│   ├── services/        # SessionManager, RatingService, FeedbackService,
│   │                    # DiscoveryService, LocalMetadataProvider, LastFmProvider, QlooProvider
│   ├── state/           # PlayerController (ChangeNotifier, Smart Shuffle)
│   └── youtube/         # YtBridge (MethodChannel to Chaquopy Python)
│
├── lib/ui/
│   ├── discovery_page.dart       # Stream-first discovery feed
│   ├── now_playing_page.dart     # Rating widget, Smart Shuffle indicator, Track Radio
│   ├── playlist_songs_page.dart  # Reorderable playlist tracks
│   ├── debug_page.dart           # Diagnostics developer screen
│   └── widgets/
│       ├── rating_widget.dart        # Interactive 10-star rating
│       ├── similar_tracks_sheet.dart # Track Radio bottom sheet
│       └── synced_lyrics_view.dart   # Tap-to-seek synchronized lyrics
│
└── android/app/src/main/
    ├── kotlin/                   # MainActivity MethodChannel bindings
    └── python/ytdlp.py           # yt-dlp canonical audio extraction & ID3 mutagen tagging
```

---

## Automated Test Suite

The project includes unit and integration tests covering the engineering specification:

```powershell
& "flutter" test
```

### Test Coverage (20 / 20 Passing):
1. **Specification §51 Session Scenarios 1–8**:
   - Continuous activity within 1 hour stays in same session.
   - Inactivity gap $\ge 1\text{ hour}$ creates a new session.
   - App closes 10:30, reopens 10:50 ($<1\text{h}$) $\rightarrow$ Same session.
   - App closes 10:30, reopens 12:00 ($\ge 1\text{h}$) $\rightarrow$ New session.
   - Pause 10:30, resume 10:40 ($<1\text{h}$) $\rightarrow$ Same session.
   - Pause 10:30, resume 11:31 ($\ge 1\text{h}$) $\rightarrow$ New session.
   - Backgrounded $<1\text{h}$ $\rightarrow$ Same session on resume.
   - Backgrounded $>1\text{h}$ $\rightarrow$ New session on resume.
2. **Ratings & History**: 1–10 rating persistence, cross-session consistency calculation, volatility penalty.
3. **Implicit Feedback**: Duration-weighted skips penalizing early skips ($<20\%$) more than late skips ($>80\%$).
4. **Lyrics**: LRC timestamp parser and unsynchronized fallback.
5. **Shuffle & Spacing**: Normal shuffle preservation and Smart Shuffle artist diversity spacing.
6. **Discovery & Radio**: Offline acoustic similarity ranking, track radio generation, download promotion, and cache cleanup.

Static analysis:
```powershell
& "flutter" analyze
# Result: No issues found! (0 errors, 0 warnings)
```

---

## Getting Started & Build Instructions

### Prerequisites
* Flutter SDK (`^3.12.2` or later)
* Android Studio / Android SDK (API 34)
* Java 17+

### Running the App
```powershell
cd app
flutter pub get
flutter run
```

### Building Release APK
```powershell
cd app
flutter build apk --release --target-platform android-arm64
```
The APK will be generated at `app/build/app/outputs/flutter-apk/app-release.apk`.
