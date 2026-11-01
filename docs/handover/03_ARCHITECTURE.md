# 03 — Spotless Architecture and System Design

> **Document Version**: 1.0.0  
> **Date**: November 1, 2026  

---

## 1. High-Level Architectural Pattern

Spotless employs a **Layered Architecture with a Centralized Facade & Unidirectional Reactive State Flow**:

1. **Presentation Layer (UI)**: Built with Flutter Material 3 Expressive components. UI widgets **never** talk directly to SQLite, ExoPlayer, or Python. They communicate exclusively through `PlayerController` (for playback & queue state) and `MusicRepository` (for queries, playlists, and catalog actions).
2. **State Management Layer**: Implemented using `ChangeNotifier` and Flutter `Provider`. `PlayerController` is the authoritative owner of the active queue, shuffle sequence, position, and playback flags. `DynamicThemeProvider` extracts palettes from album art to drive ambient styling.
3. **Facade Layer (`MusicRepository`)**: The boundary between UI and backend subsystems. Encapsulates SQLite database operations, external provider orchestration, download queuing, cover caching, and library imports.
4. **Audio Engine Layer (`AudioEngine`)**: Wraps `just_audio` and `audio_service`, running ExoPlayer natively on Android. Coordinates background media notifications, dual-player crossfades, and ~200ms position ticking.
5. **Native Interop Layer (`YtBridge` & Chaquopy)**: A Flutter `MethodChannel` (`spotless/ytdlp`) dispatching tasks to an embedded Python 3.12 runtime running `yt-dlp` and `mutagen` on a dedicated background worker thread.
6. **Data Persistence Layer (Drift SQLite)**: Relational schema v3 with 8 tables storing catalog metadata, lyrics, playlists, sessions, ratings, playback events, and discovery candidates.

---

## 2. Minimum Architectural Diagrams

### A. High-Level Architecture Diagram

```mermaid
graph TD
    subgraph UI ["Presentation Layer (Flutter UI)"]
        Pages["Screens (Home, Library, NowPlaying, Discovery, Search, Playlists)"]
        Widgets["Widgets (WavySlider, MiniPlayer, RatingWidget, SyncedLyricsView)"]
        Theme["DynamicThemeProvider (PaletteGenerator)"]
    end

    subgraph State ["State Management Layer"]
        PC["PlayerController (ChangeNotifier)"]
    end

    subgraph Facade ["Service Facade"]
        Repo["MusicRepository (Facade)"]
    end

    subgraph Services ["Core Services & Providers"]
        SM["SessionManager"]
        RS["RatingService"]
        FS["FeedbackService"]
        DS["DiscoveryService"]
        Scanner["LibraryScanner"]
        Downloader["Downloader"]
        Covers["CoverService"]
        LrcP["LrcParser"]
        LocalProv["LocalMetadataProvider"]
        LastFmProv["LastFmProvider"]
        QlooProv["QlooProvider"]
    end

    subgraph Storage ["Local Storage & Cache"]
        DB[(Drift SQLite DB: spotless.sqlite)]
        Prefs[SharedPreferences]
        Files[App Filesystem: downloads/, covers/, exports/]
    end

    subgraph Native ["Android Platform & Interop Layer"]
        AE["AudioEngine (BaseAudioHandler)"]
        AS["AudioService (Foreground Service)"]
        Exo["ExoPlayer (Android Media3)"]
        Bridge["YtBridge (MethodChannel: spotless/ytdlp)"]
        KT["MainActivity.kt (SingleThreadExecutor)"]
        PY["ytdlp.py (Chaquopy Python 3.12)"]
    end

    subgraph Ext ["External Web Services"]
        YT["YouTube CDN (googlevideo streams)"]
        LRCLIB["lrclib.net (Lyrics API)"]
        LASTFM["Last.fm API"]
        QLOO["Qloo Taste API"]
    end

    %% Connections
    Pages --> PC
    Widgets --> PC
    Pages --> Repo
    Theme --> PC
    Theme --> Repo

    PC --> Repo
    PC --> AE

    Repo --> DB
    Repo --> Prefs
    Repo --> Files
    Repo --> SM
    Repo --> RS
    Repo --> FS
    Repo --> DS
    Repo --> Scanner
    Repo --> Downloader
    Repo --> Covers
    Repo --> Bridge

    DS --> LocalProv
    DS --> LastFmProv
    DS --> QlooProv
    DS --> SM
    DS --> RS
    DS --> FS

    LocalProv --> DB
    LastFmProv --> LASTFM
    QlooProv --> QLOO

    AE --> AS
    AE --> Exo
    Exo --> YT

    Bridge --> KT
    KT --> PY
    PY --> YT
    PY --> LRCLIB
    PY --> Files
```

---

### B. Playback Architecture Diagram (Track Selection to Audio Output)

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant UI as NowPlaying / SongTile
    participant PC as PlayerController
    participant Repo as MusicRepository
    participant Engine as AudioEngine
    participant Exo as Android ExoPlayer
    participant Bridge as YtBridge / ytdlp.py
    participant Proxy as Loopback Proxy (127.0.0.1)

    User->>UI: Tap Song / Play Queue
    UI->>PC: playQueue([SongRow], startIndex)
    PC->>PC: Set _current, generate shuffle order
    PC->>Engine: setQueue(MediaItems, startAt, order)
    Engine->>PC: resolver(queueIndex) callback
    PC->>Repo: resolve(song)

    alt Song is Downloaded
        Repo-->>PC: ResolvedPlayable(localPath, isStream: false)
        PC-->>Engine: url = localPath, headers = {}
        Engine->>Engine: _sourceFor(): isLocal == true
        Engine->>Exo: AudioSource.uri(Uri.file(path), headers: null)
        Note over Engine,Exo: Headers MUST be null to bypass proxy!
    else Song is Streamable
        Repo->>Bridge: extract("https://youtube.com/watch?v=" + youtubeId)
        Bridge-->>Repo: {url: "https://...googlevideo.com/...", headers: {...}}
        Repo-->>PC: ResolvedPlayable(streamUrl, headers, isStream: true)
        PC-->>Engine: url = streamUrl, headers = headers
        Engine->>Engine: _sourceFor(): isLocal == false
        Engine->>Proxy: Route through 127.0.0.1 with User-Agent headers
        Proxy->>Exo: Stream raw audio data
    end

    Exo->>Engine: playbackEventStream (buffering -> ready)
    Engine->>PC: onSongChanged(queueIndex)
    PC->>Repo: recordPlay(song)
    PC->>Repo: lyricsFor(song)
    Repo-->>PC: Lyrics (synced or plain)
    PC->>UI: notifyListeners() (update art, title, lyrics, status)

    loop Every ~200ms while Playing
        Engine->>Engine: Position Ticker (_tickInterval)
        Engine->>PC: playbackState.copyWith(updatePosition)
        PC->>UI: notifyListeners() (update WavySlider & active lyric line)
    end
```

---

### C. Data-Flow Diagram (Metadata, Feedback, Sessions & Recommendations)

```mermaid
flowchart TD
    subgraph Inputs ["Input Events"]
        CSV["Spotify Export CSVs (songs.csv, sleep.csv)"]
        Play["Play Start / Progress Events"]
        Skip["Track Skip (<20% or >80%)"]
        Rate["Explicit 1-10 Star Rating"]
        DiscStream["Discovery Stream Interaction"]
    end

    subgraph Processing ["Logic & Processing Pipeline"]
        Scanner["LibraryScanner"]
        SM["SessionManager (1-Hour Inactivity Rule)"]
        FS["FeedbackService"]
        RS["RatingService"]
        DS["DiscoveryService"]
    end

    subgraph Database ["Drift SQLite Persistence"]
        T_Songs[("Songs Table<br/>acoustic features, playCount, likedAt")]
        T_Sessions[("ListeningSessions Table<br/>startedAt, lastActivityAt, state")]
        T_Ratings[("RatingEvents Table<br/>rating 1-10, timestamp, sessionId")]
        T_Events[("PlaybackEvents Table<br/>play_start, completed, skip pct")]
        T_Discovery[("DiscoveryCandidates Table<br/>score, provider, status")]
    end

    subgraph Consumers ["Intelligence Consumers"]
        SmartShuffle["Smart Shuffle Engine (PlayerController)"]
        Radio["Track Radio Sheet (SimilarTracksSheet)"]
        DiscPage["Discovery Feed Page (DiscoveryPage)"]
    end

    %% Data flow mapping
    CSV --> Scanner --> T_Songs
    Play --> SM --> T_Sessions
    Play --> FS --> T_Events
    Skip --> FS --> T_Events
    Rate --> RS --> T_Ratings
    Rate --> SM
    Rate --> T_Songs

    DiscStream --> DS --> T_Discovery

    T_Songs & T_Ratings & T_Events --> SmartShuffle
    T_Songs & T_Sessions & T_Ratings & T_Events --> DS
    DS --> Radio
    DS --> DiscPage

    DiscPage --"Rating >= 8 (Promotion)"--> DS
    DS --"Upsert to Library"--> T_Songs
```

---

### D. State Management & Ownership Diagram

```mermaid
graph LR
    subgraph Singletons ["Service Layer Singletons (Injected via Provider)"]
        Repo["MusicRepository"]
        Engine["AudioEngine"]
    end

    subgraph StateHolders ["Authoritative State Holders"]
        PC["PlayerController (ChangeNotifier)<br/>- _queue: List&lt;SongRow&gt;<br/>- _shuffleOrder: List&lt;int&gt;<br/>- _current: int<br/>- _shuffleMode: off/normal/smart<br/>- _repeat: off/all/one<br/>- _position: Duration<br/>- _duration: Duration<br/>- _currentLyrics: Lyrics?<br/>- _downloadProgress: double"]
        Theme["DynamicThemeProvider (ChangeNotifier)<br/>- scheme: ColorScheme<br/>- dominantColor: Color"]
    end

    subgraph Consumers ["Consuming Widgets & Pages"]
        NowPlaying["NowPlayingPage<br/>(art, wavy slider, pill controls)"]
        MiniPlayer["MiniPlayer<br/>(frosted glass, compact controls)"]
        Lyrics["LyricsPage & SyncedLyricsView<br/>(active line highlight, tap-to-seek)"]
        Home["HomePage<br/>(Your Mix collage, carousels)"]
        Library["LibraryPage<br/>(tabbed lists, song tiles)"]
        Discovery["DiscoveryPage<br/>(candidate cards, rating bar)"]
    end

    Repo --> PC
    Engine --> PC
    PC --> Theme

    PC -->|context.watch| NowPlaying
    PC -->|context.watch| MiniPlayer
    PC -->|context.watch| Lyrics
    PC -->|context.watch| Home
    PC -->|context.watch| Library
    PC -->|context.watch| Discovery

    Theme -->|context.watch| NowPlaying
    Theme -->|context.watch| MiniPlayer
    Theme -->|context.watch| Lyrics
    Theme -->|context.watch| Home
```

---

### E. Background-Task Architecture (Downloads & Media Playback)

```mermaid
graph TD
    subgraph UIThread ["Flutter UI Thread (Dart VM)"]
        UI["Now Playing / Settings / Search"]
        DLCall["repo.downloadSong() / repo.importPlaylistCsvs()"]
        Poller["Downloader.pollProgress() (Timer @ 500ms)"]
    end

    subgraph AndroidMain ["Android Main Process"]
        ASActivity["MainActivity (AudioServiceActivity)"]
        Service["com.ryanheise.audioservice.AudioService (Foreground)"]
        Receiver["MediaButtonReceiver"]
        Notif["Android System Notification Drawer (MediaStyle)"]
        Lockscreen["Lock Screen Media Controls"]
    end

    subgraph PythonWorker ["Native Python Worker (Chaquopy)"]
        Exec["Executors.newSingleThreadExecutor() (Kotlin)"]
        PyModule["ytdlp.py (Chaquopy Engine)"]
        ProgFile["$HOME/ytdlp_progress.txt ('pct|done|total')"]
        DiskFile["files/spotless/downloads/dl_*.m4a|mp3"]
    end

    %% Flow
    UI --> DLCall
    DLCall -->|MethodChannel 'download'| ASActivity
    ASActivity -->|Callable submission| Exec
    Exec -->|Blocking run| PyModule
    PyModule -->|yt-dlp hook| ProgFile
    PyModule -->|writes audio| DiskFile
    PyModule -->|mutagen tagging| DiskFile

    Poller -->|MethodChannel 'getProgress'| ASActivity
    ASActivity -->|reads| ProgFile
    ProgFile -->|progress string| Poller
    Poller --> UI

    Service --> Notif
    Service --> Lockscreen
    Receiver --> Service
    Service -->|Callbacks| ASActivity
```

---

## 3. Explaining Important Architectural Connections

### 3.1 The ExoPlayer Localhost Proxy Bypass (`_sourceFor`)
When ExoPlayer requests an audio stream, `just_audio` inspects the `AudioSource.uri(uri, headers: headers)` call:
- If `headers` is **not null** (even an empty map `{}`), `just_audio` spins up an internal HTTP proxy at `http://127.0.0.1:<random_port>/...`.
- If the URI is a local path (`/storage/...`), passing headers makes ExoPlayer attempt cleartext HTTP to `127.0.0.1`.
- Android 9+ blocks cleartext HTTP by default.
- **Solution in Spotless**:
  1. `AudioEngine._sourceFor()` verifies `uri.scheme.isEmpty || uri.scheme == 'file'`. If true, it wraps as `Uri.file(path)` and enforces `headers: null`.
  2. For remote streams (`googlevideo.com`), headers are required for YouTube bot bypass. `android/app/src/main/res/xml/network_security_config.xml` explicitly allows cleartext traffic to `127.0.0.1` and `localhost`.

### 3.2 Dual-Player Audio Crossfade (`_player` & `_aux`)
`AudioEngine` owns two instances of `AudioPlayer`:
1. When song A approaches completion or the user taps next, `_aux` loads song B at `volume = 0.0`.
2. `unawaited(_aux.play())` starts playback on `_aux` immediately.
3. `_fadeVolume` executes 16 discrete volume steps over 4 seconds: `_player` ramps from 1.0 to 0.0 while `_aux` ramps from 0.0 to 1.0.
4. Once completed, `old.stop()` shuts down the previous track, the references swap (`_player = next; _aux = old;`), and event listeners are reattached.

### 3.3 MethodChannel Python Interop & Thread Safety
Chaquopy runs Python inside the Android JVM. In `MainActivity.kt`:
- Calls to `ytdlp.py` are submitted as a `java.util.concurrent.Callable<PyObject>` to a `singleThreadExecutor`.
- The platform channel thread never blocks on Python; a dedicated daemon `waiter` thread awaits `future.get(timeoutSecs, TimeUnit.SECONDS)`.
- If a download or network call hangs, it aborts after 300s (or 90s for metadata) with a clean `YTDLP_ERROR` platform exception rather than freezing the Flutter UI.
- All Python return values are JSON strings (`json.dumps(..., ensure_ascii=False)`), preventing encoding corruptions across the native JNI boundary.
