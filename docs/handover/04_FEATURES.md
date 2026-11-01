# 04 — Detailed Feature-by-Feature Technical Documentation

> **Document Version**: 1.0.0  
> **Date**: November 1, 2026  

---

## 1. Feature 5.1: Music Discovery and Search

### 1.1 Purpose
Provides a unified search interface allowing users to find songs in their local library (by title, artist, or lyrics content) or search YouTube for streaming and downloading.

### 1.2 User-Facing Behaviour
- Located on the middle tab of `HomeShell` (`SearchPage`).
- Segmented button at the top toggles between **Local** and **YouTube** modes.
- In **Local** mode:
  - Typing filters songs instantly across titles, artists, and full-text lyrics (`LyricsTable.content`).
  - Tapping a local result plays it immediately in `PlayerController`.
  - Swipe actions allow adding to playlist or toggling like.
  - Respects the "Offline only" filter toggle.
- In **YouTube** mode:
  - Submits search query to YouTube via `yt-dlp` `extract_flat: in_playlist` (~2s response time).
  - Tapping a result plays it via streaming (`player.playQueue([song])`) and opens Now Playing.
  - Download icon button downloads the song into local storage for offline listening.
- When search input is idle/empty:
  - Displays recent search history chips (capped at 10 items) and a "Clear" button.

### 1.3 Key Source Files, Classes & Functions
- [app/lib/ui/search_page.dart](file:///d:/Nandhu/spotify/app/lib/ui/search_page.dart): `SearchPage`, `_SearchPageState._runSearch`, `_SearchIdle`.
- [app/lib/core/services/music_repository.dart](file:///d:/Nandhu/spotify/app/lib/core/services/music_repository.dart): `searchSongs(query, {offlineOnly})`, `searchYoutube(query)`, `searchHistory()`, `addSearchHistory(q)`.
- [app/android/app/src/main/python/ytdlp.py](file:///d:/Nandhu/spotify/app/android/app/src/main/python/ytdlp.py): `search(query, max_results=10)`.

### 1.4 Execution Flow
```
User types query in SearchPage
 │
 ├── If Mode == Local:
 │   └── repo.searchSongs(query)
 │       └── Drift SQLite query on `db.songs` joined with `db.lyricsTable`
 │           └── Returns List<SongRow> -> Updates UI ListView
 │
 └── If Mode == YouTube:
     └── repo.searchYoutube(query)
         └── yt.search(query) -> MethodChannel('spotless/ytdlp', 'search')
             └── MainActivity.kt -> ytdlp.py `search()`
                 └── yt_dlp.YoutubeDL(opts).extract_info("ytsearch15:query")
                     └── Returns List<Map> -> Decoded in Dart -> Displayed in ListView
```

### 1.5 Database & Data Structures
- **Database Query**:
  ```dart
  final lyricMatch = db.selectOnly(db.lyricsTable)
    ..addColumns([db.lyricsTable.songId])
    ..where(db.lyricsTable.content.lower().like(like));
  q.where((t) => t.title.lower().like(like) | t.artist.lower().like(like) | t.id.isInQuery(lyricMatch));
  ```
- **History Storage**: Stored as a JSON string list in `SharedPreferences` under key `'search_history'`.

### 1.6 Edge Cases & Error Handling
- **SQL Wildcards**: Input `%` and `_` characters are stripped before building the `like` expression to prevent SQL pattern injection.
- **Empty Query**: Empty input returns immediately without making network or database calls.
- **YouTube Timeout**: If YouTube search takes $>90\text{s}$, Kotlin waiter aborts with `YTDLP_ERROR: Timed out`.

---

## 2. Feature 5.2: YouTube Integration

### 2.1 Purpose
Enables streaming and metadata extraction for non-downloaded tracks without relying on broken pure-Dart libraries.

### 2.2 Mechanism
- **Engine**: Real Python `yt-dlp` (pinned at `2026.7.4`) embedded inside Android via **Chaquopy 17.0.0**.
- **Player Clients**: Configured in `BASE_OPTS`:
  ```python
  "player_client": ["android_vr", "tv_embedded", "android_creator", "ios"]
  ```
  *Why*: In 2026, YouTube's standard `"android"` client returns only storyboard image formats (`ext: mhtml`, `acodec: none`). Using `android_vr`, `tv_embedded`, and `android_creator` reliably yields audio-only streams (m4a format 140, opus format 251).
- **Format Filter**: `_pick_audio()` filters out storyboard entries and sorts by average audio bitrate (`abr`).

### 2.3 Streaming URL Expiry & Lifecycle
- Extracted `googlevideo.com` URLs expire after a few hours.
- URLs are **never persisted** to SQLite.
- `AudioEngine` caches URLs in memory (`_urls[song.id]`). If playback drops to `idle` unexpectedly (indicating HTTP 403 or URL expiration), `_onProcessingState` discards the cache and re-extracts a fresh URL.

### 2.4 Canonical Studio Recording Search
- Implemented in `canonical_search()` inside `ytdlp.py`.
- Evaluates candidate YouTube results with a 50.0 base score:
  - **Penalties (-20)**: `live`, `concert`, `performance`, `cover`, `remix`, `karaoke`, `instrumental`, `sped up`, `slowed`, `nightcore`, `fan-made`.
  - **Bonuses (+15)**: `official audio`, `official music`, `official video`.
  - **Official Channel Hints (+10)**: `vevo`, `records`, `music`, `official`, `entertainment`.
  - **Artist in Channel (+15)**, **Artist in Title (+5)**.
  - **Duration Divergence**: Divergence $\le 5\text{s}$ gets $+10$; divergence $>60\text{s}$ gets $-25$.

---

## 3. Feature 5.3: Download System

### 3.1 Purpose
Downloads YouTube audio streams directly into the app's local private storage, tags them with ID3/MP4 metadata, embeds album art, and registers them into the SQLite database.

### 3.2 Storage Locations & Naming
- **Directory**: `<appSupportDir>/spotless/downloads/` (`files/spotless/downloads/` on Android).
- **Base Filename**: `dl_<timestamp>.<ext>` (typically `.m4a` or `.opus` or `.mp3`).
- **Persistence**: Upon completion, `MusicRepository._finalizeDownload()` updates `db.songs`:
  - `status = 'downloaded'`
  - `localPath = '<full path>'`
  - `filename = '<basename>'`
  - `durationMs = <probed duration>`
  - `resolvedYtTitle = '<title from yt-dlp>'`

### 3.3 Progress Tracking
- `yt-dlp`'s `_progress_hook` writes progress to `$HOME/ytdlp_progress.txt` in format `pct|downloaded_bytes|total_bytes`.
- Flutter `Downloader.pollProgress()` polls this file via MethodChannel every 500ms and updates the UI progress bar.

### 3.4 Tagging & Post-Processing
1. **Tagging**: Mutagen `EasyID3` (for MP3) or `MP4` (for M4A) writes `title` and `artist`.
2. **Artwork**: Fetches `albumArtUrl` over HTTP and embeds it as an `APIC` frame (MP3) or `covr` box (MP4).
3. **Lyrics**: Calls `ytdlp.fetch_lyrics()` from `lrclib.net` and persists into `LyricsTable` (`type = 'lrc'` or `'txt'`).

---

## 4. Feature 5.4: Audio Playback Engine

### 4.1 Playback Components
- **Core Player**: `just_audio` (version `0.10.6`) running on Android Media3 ExoPlayer.
- **Background Service**: `audio_service` (version `0.18.19`) with `BaseAudioHandler`.
- **Authoritative Controller**: `PlayerController` (ChangeNotifier).

### 4.2 Queue Management & Resolution
- Playback queue is represented as `List<SongRow> _queue` in `PlayerController`.
- `AudioEngine` maintains a list of `MediaItem` objects.
- **Lazy Resolution**: Tracks are resolved just before playback starts (`resolver: _resolveUri`). Local tracks play immediately via file URI; remote tracks invoke `MusicRepository.resolve()` to get streaming URLs.

### 4.3 Dual-Player Audio Crossfade
- `AudioEngine` maintains `_player` (active) and `_aux` (secondary).
- When a track advances, `_aux` starts playing the next song at `volume = 0.0` using `unawaited(_aux.play())`.
- Over a 4-second window, 16 volume steps ramp `_player` down to 0.0 and `_aux` up to 1.0.
- `_player` is stopped, references swap, and notification media items are updated.
- Setting `crossfade = Duration.zero` disables crossfading.

### 4.4 Position Ticking
- Instead of relying on coarse platform streams, `AudioEngine` runs a periodic `Timer` every 200ms (`_tickInterval`).
- It samples `_player.position` and publishes a `PlaybackState` update so seek bars and lyrics update smoothly.

---

## 5. Feature 5.5: Synchronized Lyrics

### 5.1 Storage & Formats
- Stored in SQLite `LyricsTable`:
  - `songId` (Text PK)
  - `type` (`'lrc'` for synchronized, `'txt'` for plain)
  - `content` (Full text)

### 5.2 LRC Parsing (`LrcParser`)
- Parses timestamp patterns `[mm:ss.xx]` or `[mm:ss:xxx]`.
- Handles fractional seconds (1 digit = deciseconds, 2 digits = centiseconds, 3 digits = milliseconds).
- Strips header tags: `[ti:]`, `[ar:]`, `[al:]`, `[by:]`, `[offset:]`.
- Returns a sorted `Lyrics` object containing `List<LyricLine>`.

### 5.3 Interactive Synced Lyrics View (`SyncedLyricsView`)
- Matches current position: iterates through lines to find the greatest timestamp $\le \text{player.position}$.
- **Active Line Highlighting**: Active line rendered in bold 22sp white; upcoming lines in 20sp medium white; past lines dimmed.
- **Auto-Scrolling**: Uses `ScrollController.animateTo()` with `Curves.easeOutCubic` over 400ms to center the active line in the viewport.
- **Tap-to-Seek**: Tapping any lyric line executes `_player.seek(lines[index].time)`, immediately jumping playback.

---

## 6. Feature 5.6: Playlists

### 6.1 Database Representation
- **Table `Playlists`**: `id` (Text PK, e.g. `'pl_1730000000'`), `name` (Text), `createdAt` (DateTime).
- **Table `PlaylistSongs`**: `playlistId` (Text), `songId` (Text), `position` (Int). Composite PK: `{playlistId, songId}`.

### 6.2 Operations
- **Creation**: Generates timestamped ID `pl_<ms>`.
- **Addition (`addToPlaylist`)**: Idempotent. If the song is a non-downloaded YouTube search result, a stub row is inserted into `Songs` table (`status = 'streamable'`) to prevent broken inner joins.
- **Drag-and-Drop Reordering**: Handled via `ReorderableListView.builder` in `playlist_songs_page.dart`. Updates `position` column inside a database transaction.
- **Export to M3U**: Writes standard `#EXTM3U` and `#EXTINF` entries to `<appSupport>/spotless/exports/<name>.m3u` and triggers Android share sheet using `share_plus`.

---

## 7. Feature 5.7: Recommendation and Discovery Engine

### 7.1 Multi-Component Scoring Algorithm
Implemented in `DiscoveryService._filterRankAndPersist()`:
$$\text{finalScore} = (\text{providerScore} \times \text{externalWeight}) + \text{noveltyBonus} - \text{penalties}$$
- `externalWeight` = 0.20
- `noveltyBonus` = 0.10
- `negativeFeedbackPenalty` = 0.40 (applied if candidate was previously marked `'rejected'`)
- `repetitionPenalty` = 0.25 (applied if candidate was previously streamed)

### 7.2 Providers
1. **Local Metadata Provider (`LocalMetadataProvider`)**: Computes 4D Euclidean distance between Spotify audio features:
   $$\text{dist} = \sqrt{(e_1-e_2)^2 + \left(\frac{t_1-t_2}{60}\right)^2 + (v_1-v_2)^2 + (d_1-d_2)^2} - (0.15 \times \text{genreOverlap})$$
2. **Last.fm Provider (`LastFmProvider`)**: Calls `track.getsimilar` using configured user API key.
3. **Qloo Provider (`QlooProvider`)**: Calls `/v2/insights` with entity type music.

### 7.3 Stream-First & Promotion Workflow
- Discovery tracks appear in `DiscoveryPage` with status `'candidate'`.
- Tapping a track streams it directly from YouTube without downloading.
- If the user rates the track $\ge 8$ or taps "Promote", `promoteCandidate()` adds the song to `db.songs` and downloads it to the permanent library.
- Unpromoted candidates older than 14 days (`AppConfig.discoveryCacheLifetime`) are purged on startup via `cleanupStaleCandidates()`.

---

## 8. Feature 5.8: Rating and Feedback System

### 8.1 1–10 Rating System
- Implemented in `RatingService` and `RatingWidget`.
- Interactive 10-star rating bar.
- Every rating creates a new row in `RatingEvents`:
  - `id`: Unique event ID
  - `songId`: Target track
  - `sessionId`: Currently active listening session
  - `rating`: 1 to 10
  - `timestamp`: Event time
- **History Preservation**: Past ratings are never overwritten or deleted.
- **Consistency Scoring**: Calculates rating variance and cross-session stability. Volatile ratings indicate mood spikes; steady high ratings indicate long-term preference.
- **Liked Sync**: Ratings $\ge 8$ automatically set `likedAt` in the `Songs` table.

### 8.2 Implicit Feedback Tracking
- Implemented in `FeedbackService`.
- Records events in `PlaybackEvents`:
  - `play_start`: Playback initiated.
  - `completed`: Track played to 100% (+0.3 bonus).
  - `replay`: Track immediately replayed (+0.4 bonus).
  - `skip`: Track skipped before completion.
    - Early skip ($<20\%$ completion): strong penalty ($-0.3$).
    - Mid skip ($20\% - 60\%$ completion): standard penalty ($-0.2$).
    - Late skip ($>60\%$ completion): negligible penalty ($-0.06$).

---

## 9. Feature 5.9: Listening Sessions and User Taste

### 9.1 The Inactivity Session Model
- Implemented in `SessionManager` according to **Specification §51**.
- **Definition**: A session is a contiguous block of listening activity.
- **The 1-Hour Cutoff**:
  - Any activity within 1 hour of the previous activity continues the current session (`lastActivityAt` updated).
  - An inactivity gap of $\ge 1\text{ hour}$ seals the previous session (`state = 'completed'`, `endedAt = lastActivityAt`) and begins a new session upon the next activity.
- **Zero Clock-of-Day Heuristics**: The app **never** creates morning, afternoon, evening, night, or weekend preference clusters.
- **Persistence Across Process Restarts**: Sessions are stored in SQLite `ListeningSessions`. Backgrounding, swiping the app away, or OS activity recreation does NOT terminate a session if the user returns within 1 hour.
- **App Launch vs Activity**: Merely opening the app does not create a session. A session is created only when meaningful interaction occurs (playback start, seek, rate, skip).
