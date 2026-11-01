# 05 — Database and Data Model Documentation

> **Document Version**: 1.0.0  
> **Date**: November 1, 2026  
> **Technology**: Drift 2.34.3 SQLite ORM (`drift_flutter` 0.3.1)  
> **Database File**: `app_flutter/spotless.sqlite` on Android  
> **Current Schema Version**: 3  

---

## 1. Entity-Relationship Diagram (Drift Schema v3)

```mermaid
erDiagram
    SONGS ||--o| LYRICS_TABLE : "has lyrics"
    SONGS ||--o{ PLAYLIST_SONGS : "included in"
    PLAYLISTS ||--o{ PLAYLIST_SONGS : "contains"
    SONGS ||--o{ RATING_EVENTS : "rated by"
    LISTENING_SESSIONS ||--o{ RATING_EVENTS : "records"
    SONGS ||--o{ PLAYBACK_EVENTS : "playback for"
    LISTENING_SESSIONS ||--o{ PLAYBACK_EVENTS : "occurred during"
    SONGS ||--o{ DISCOVERY_CANDIDATES : "seeded by"
    LISTENING_SESSIONS ||--o{ DISCOVERY_CANDIDATES : "generated in"

    SONGS {
        text id PK "File index (0000001) or Spotify URI"
        text filename "0000001.mp3"
        text title "Track title"
        text artist "Artist name"
        text album "Album name"
        text youtubeId "YouTube 11-char ID"
        text localPath "Full filesystem path"
        text status "downloaded, streamable, missing, analyzing, failed"
        int durationMs "Duration in milliseconds"
        text albumArtUrl "Spotify or YouTube thumbnail URL"
        text albumArtPath "Cached cover path"
        bool artEmbedded "Whether ID3 APIC is embedded"
        text trackUri "spotify:track:..."
        text isrc "International Standard Recording Code"
        int trackNumber "Track number in album"
        bool explicit "Explicit lyrics flag"
        int popularity "Spotify popularity (0-100)"
        text genres "Comma-separated genres"
        real danceability "Acoustic feature (0.0-1.0)"
        real energy "Acoustic feature (0.0-1.0)"
        int key "Pitch class (0-11)"
        real loudness "Overall loudness in dB"
        int mode "Major (1) or Minor (0)"
        real speechiness "Spoken word ratio (0.0-1.0)"
        real acousticness "Acoustic ratio (0.0-1.0)"
        real instrumentalness "Instrumental ratio (0.0-1.0)"
        real liveness "Audience presence (0.0-1.0)"
        real valence "Musical positiveness (0.0-1.0)"
        real tempo "Estimated BPM"
        int timeSignature "Estimated time signature"
        datetime addedAt "Timestamp added to Spotify"
        int sleepOrder "Position in legacy Sleep CSV"
        int noSleepOrder "Position in legacy No Sleep CSV"
        datetime lastPlayedAt "Timestamp of last playback"
        int playCount "Total play count"
        datetime likedAt "Timestamp when liked"
        text resolvedYtTitle "Title extracted from YouTube"
        text error "Last download or playback error"
    }

    LYRICS_TABLE {
        text songId PK "References Songs.id"
        text type "'lrc' or 'txt'"
        text content "Raw lyrics text"
    }

    PLAYLISTS {
        text id PK "'sleep', 'no_sleep', or 'pl_<ms>'"
        text name "Display name"
        datetime createdAt "Creation timestamp"
    }

    PLAYLIST_SONGS {
        text playlistId PK "References Playlists.id"
        text songId PK "References Songs.id"
        int position "Ordering index in playlist"
    }

    LISTENING_SESSIONS {
        text id PK "'sess_<timestamp>_<us>'"
        datetime startedAt "First activity timestamp"
        datetime lastActivityAt "Most recent activity timestamp"
        datetime endedAt "Session end timestamp (null if active)"
        text state "'active' or 'completed'"
    }

    RATING_EVENTS {
        text id PK "'rate_<timestamp>_<rand>'"
        text songId "References Songs.id"
        text sessionId "References ListeningSessions.id"
        int rating "1 to 10"
        datetime timestamp "Rating timestamp"
    }

    PLAYBACK_EVENTS {
        text id PK "'play_' | 'comp_' | 'skip_' | 'rep_'"
        text songId "References Songs.id"
        text sessionId "References ListeningSessions.id"
        text eventType "'play_start', 'completed', 'skip', 'replay', 'seek'"
        int secondsPlayed "Seconds listened before event"
        real completionPercentage "0.0 to 1.0"
        datetime timestamp "Event timestamp"
    }

    DISCOVERY_CANDIDATES {
        text id PK "'disc_<artist>_<title>'"
        text title "Track title"
        text artist "Artist name"
        text album "Album name"
        text youtubeId "YouTube ID"
        int durationMs "Duration in milliseconds"
        text albumArtUrl "Thumbnail URL"
        text provider "'local', 'lastfm', 'qloo'"
        text seedSongId "Seed track ID if generated from one"
        text sessionId "Active session during discovery"
        real score "Calculated ranking score"
        text status "'candidate', 'streamed', 'promoted', 'rejected'"
        datetime createdAt "Candidate creation timestamp"
        datetime lastInteractedAt "Last interaction timestamp"
    }
```

---

## 2. Table Specifications

### 2.1 `Songs` (`SongRow`)
- **Primary Key**: `id` (`TextColumn`).
  - Pre-seeded local songs: zero-padded string (`"0000001"`, `"0000002"`, ...).
  - Spotify-imported tracks: Spotify track URI (`"spotify:track:..."`) or `"imp:<playlistId>:<i>"`.
  - YouTube search tracks: `"yt:<videoId>"`.
- **Status Enum Mapping**: Stored as text column matching `SongStatus.name`:
  - `'analyzing'`: Metadata created, awaiting download.
  - `'downloaded'`: File present at `localPath` on disk.
  - `'streamable'`: YouTube ID known; playable over network.
  - `'missing'`: No local file and no YouTube ID known.
  - `'failed'`: Download or extraction failed; see `error` column.
- **Full Spotify Acoustic Vectors**: `danceability`, `energy`, `key`, `loudness`, `mode`, `speechiness`, `acousticness`, `instrumentalness`, `liveness`, `valence`, `tempo`, `timeSignature`.

### 2.2 `LyricsTable` (`LyricsTableData`)
- **Primary Key**: `songId` (`TextColumn`).
- **Columns**: `type` (`'lrc'` for synced, `'txt'` for plain), `content` (`TextColumn` storing raw lyrics).
- **Encoding**: UTF-8 encoded plain text. Supports non-Latin scripts (Telugu, Tamil, Devanagari, Japanese).

### 2.3 `Playlists` (`Playlist`)
- **Primary Key**: `id` (`TextColumn`).
- **Seeded Playlists**: Migrated from legacy CSVs:
  - `id: 'sleep'`, `name: 'Sleep'`
  - `id: 'no_sleep'`, `name: 'No Sleep'`
- **User Playlists**: `id: 'pl_<timestamp>'`.
- **Date Storage**: Stored as unix-epoch milliseconds integer in SQLite, mapped to Dart `DateTime`.

### 2.4 `PlaylistSongs` (`PlaylistSong`)
- **Composite Primary Key**: `{playlistId, songId}`.
- **Positioning**: `position` (`IntColumn`) manages drag-and-drop playlist ordering.
- **Safe Inner Join**: When adding songs that are not yet downloaded, `addToPlaylist()` inserts a stub row into `Songs` with `status = 'streamable'` so inner joins succeed.

### 2.5 `ListeningSessions` (`ListeningSession`)
- **Primary Key**: `id` (`TextColumn`, format: `sess_<ms>_<us>`).
- **Timestamps**: `startedAt`, `lastActivityAt`, `endedAt`.
- **State**: `'active'` while within the 1-hour continuity window; marked `'completed'` when gap $\ge 1\text{ hour}$.

### 2.6 `RatingEvents` (`RatingEvent`)
- **Primary Key**: `id` (`TextColumn`, format: `rate_<ms>_<random>`).
- **Rating Scale**: Enforced integer between `1` and `10`.
- **Immutability**: Past ratings are never updated or deleted. Every user rating tap generates a new historical row tied to the current session.

### 2.7 `PlaybackEvents` (`PlaybackEvent`)
- **Primary Key**: `id` (`TextColumn`, format: `<eventType>_<ms>_<random>`).
- **Event Types**:
  - `'play_start'`: Generated by `FeedbackService.recordPlayStart()`.
  - `'completed'`: Generated when track finishes (`completionPercentage = 1.0`).
  - `'skip'`: Generated when user skips before completion; stores exact `secondsPlayed` and `completionPercentage`.
  - `'replay'`: Generated when user immediately restarts the track.

### 2.8 `DiscoveryCandidates` (`DiscoveryCandidate`)
- **Primary Key**: `id` (`TextColumn`).
- **Provider Names**: `'Local Library'`, `'Last.fm'`. (Qloo removed 2026-11-01.)
- **Lifecycle**:
  - Initial: `'candidate'`
  - User plays candidate: `'streamed'`
  - User likes candidate ($\ge 8$): `'promoted'` (promoted tracks are upserted into `Songs`)
  - User dislikes candidate: `'rejected'`
- **Purge**: Unpromoted candidates older than 14 days are deleted by `cleanupStaleCandidates()`.

---

## 3. Schema Migrations (`MigrationStrategy`)

### Version 1 $\rightarrow$ Version 2
- Added `Playlists` table and `PlaylistSongs` table.
- Added `likedAt` datetime column to `Songs` table.
- Seeded `'sleep'` and `'no_sleep'` playlists using typed `PlaylistsCompanion` inserts:
  ```dart
  await db.into(db.playlists).insert(
    PlaylistsCompanion.insert(
      id: 'sleep',
      name: 'Sleep',
      createdAt: DateTime(2026, 1, 1),
    ),
  );
  ```
  *(Crucial fix: avoids raw text date string literals that fail Drift integer timestamp parsing).*
- Executed custom SQL statements to populate `playlist_songs` from `sleep_order` and `no_sleep_order`.

### Version 2 $\rightarrow$ Version 3
- Added `ListeningSessions` table.
- Added `RatingEvents` table.
- Added `PlaybackEvents` table.
- Added `DiscoveryCandidates` table.

---

## 4. Persistence Limitations & Constraints

1. **Local Filesystem Coupling**: The `Songs.localPath` column stores absolute filesystem paths (e.g., `/storage/emulated/0/Download/songs_download/music/0000001.mp3` or `/data/user/0/com.nandhu.spotless/files/spotless/downloads/dl_1730000.m4a`). If the user moves their library folder, `LibraryScanner.scan()` must be run to re-link disk paths.
2. **Single SQLite Database Connection**: Drift uses a single database connection. Background isolate tasks (such as intensive downloads) use the existing database instance via `MusicRepository`.
3. **No Network Sync**: The database is purely local to the device. There is no cloud sync or multi-device account state.
