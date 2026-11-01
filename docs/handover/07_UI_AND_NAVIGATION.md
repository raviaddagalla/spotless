# 07 — UI and Navigation Documentation

> **Document Version**: 1.0.0  
> **Date**: November 1, 2026  
> **Design Language**: PixelPlayer-Inspired Material 3 Expressive (commit `cbd2a30`)  

---

## 1. Screen Navigation Flowchart

```mermaid
graph TD
    App[SpotlessApp] --> Shell[HomeShell (IndexedStack)]

    subgraph Tabs ["3-Tab Bottom Navigation Bar"]
        Tab0["Tab 0: HomePage"]
        Tab1["Tab 1: SearchPage"]
        Tab2["Tab 2: LibraryPage"]
    end

    Shell --> Tab0
    Shell --> Tab1
    Shell --> Tab2

    subgraph Persistent ["Persistent Components"]
        Mini[MiniPlayer (Frosted Glass Pill)]
    end

    Shell --> Mini

    %% Destinations from Home
    Tab0 -->|Hero Tap / Made for You| NowPlaying[NowPlayingPage]
    Tab0 -->|Pill Tap| Discovery[DiscoveryPage]
    Tab0 -->|Icon Tap| Settings[SettingsPage]
    Tab0 -->|Icon Tap| Diagnostics[DebugPage]
    Tab0 -->|Playlist Card Tap| PlaylistSongs[PlaylistSongsPage]

    %% Destinations from Search
    Tab1 -->|Tap Result| NowPlaying
    Tab1 -->|Track 3-Dot / Swipe| PlaylistPicker[PlaylistPicker BottomSheet]

    %% Destinations from Library
    Tab2 -->|Albums Tab Tap| AlbumDetail[AlbumDetailPage]
    Tab2 -->|Artists Tab Tap| ArtistDetail[ArtistDetailPage]
    Tab2 -->|Playlists Tab Tap| PlaylistSongs
    Tab2 -->|Liked Songs Tap| LikedSongs[LikedSongsPage]
    Tab2 -->|Song Tap| NowPlaying

    %% Destinations from NowPlaying
    NowPlaying -->|Lyrics Icon| Lyrics[LyricsPage]
    NowPlaying -->|Queue Icon| QueueSheet[QueueSheet BottomSheet]
    NowPlaying -->|Track Radio Icon| SimilarSheet[SimilarTracksSheet BottomSheet]

    %% Persistent MiniPlayer navigation
    Mini -->|Tap Pill| NowPlaying
```

---

## 2. Screen-by-Screen Detailed Reference

### 2.1 `HomeShell` (`app/lib/ui/home_shell.dart`)
- **Purpose**: App root scaffold providing the bottom navigation bar and hosting the persistent floating `MiniPlayer`.
- **Route**: `'/'` (Home).
- **Tabs**:
  1. `HomePage`: Mixed cards, "Your Mix" hero collage, recently played.
  2. `SearchPage`: Unified local SQLite and YouTube search.
  3. `LibraryPage`: Tabbed local catalog (Songs, Albums, Artists, Playlists).
- **Key Behavior**: The top `AppBar` is omitted from `HomeShell`; each nested page renders its own `GradientTopBar` or custom collapsing header.

---

### 2.2 `HomePage` (`app/lib/ui/home_page.dart`)
- **Purpose**: Personalized home screen showing hero mix, quick action pills, playlists, and recommendations.
- **Components**:
  - `GradientTopBar`: Displays title with action buttons for Diagnostics (`DebugPage`) and Settings (`SettingsPage`).
  - `_YourMixHero`: PixelPlayer-style 2x2 collage of album covers with a large "Your Mix" headline and prominent Play button.
  - `_QuickActionPills`: 1-tap pills for "Discover", "Recently Played", and "Playlists".
  - `_SongCardRow`: Horizontal scrolling cards for "Recently played" and "Made for you".
  - `_PlaylistGrid`: Cards showing total song counts for user and seeded playlists.
- **State Dependencies**: Watches `MusicRepository.recent()`, `MusicRepository.forYou()`, and `MusicRepository.playlists()`.

---

### 2.3 `NowPlayingPage` (`app/lib/ui/now_playing_page.dart`)
- **Purpose**: Primary playback screen featuring album art, wavy slider, pill controls, star ratings, and track radio.
- **Route**: `'now_playing'`.
- **Components**:
  - Full-bleed ambient gradient background derived dynamically from album art via `DynamicThemeProvider`.
  - Large rounded album art with soft colored drop shadow (`BorderRadius.circular(24)`).
  - Text titles with marquee/ellipsis handling.
  - `RatingWidget`: Interactive 10-star rating bar with live feedback.
  - `WavySlider`: Sinusoidal wave progress bar.
  - `RoundedControlButton`: Large pill-shaped buttons for Previous, Play/Pause, and Next.
  - `_BottomToggleRow`: Pill container hosting Shuffle (Off/Normal/Smart), Repeat (Off/All/One), Like, Sleep Timer, and Track Radio.
  - `QueueSheet`: Modal bottom sheet with drag-and-drop item reordering (`ReorderableListView`).

---

### 2.4 `LyricsPage` (`app/lib/ui/lyrics_page.dart`)
- **Purpose**: Dedicated full-screen immersive synchronized lyrics screen.
- **Components**:
  - Dynamic ambient background matching the current song.
  - Synced / Static toggle pill header.
  - `SyncedLyricsView`: Auto-scrolling list of lyric lines with tap-to-seek.
  - Bottom wavy progress bar and time labels.

---

### 2.5 `LibraryPage` (`app/lib/ui/library_page.dart`)
- **Purpose**: Complete catalog navigation organized into 4 horizontal tabs.
- **Tabs**:
  1. **SONGS**: Filterable list of all songs, offline chip toggle, alphabetized or date-added sort.
  2. **ALBUMS**: Grid of album cards with artwork and track counts (`albums_page.dart`).
  3. **ARTISTS**: Alphabetical list of artists with song counts (`artists_page.dart`).
  4. **PLAYLISTS**: Management page for creating, renaming, deleting, and exporting playlists (`playlists_page.dart`).
- **Floating Action Button**: Prominent "Shuffle All" FAB in the bottom right corner.

---

### 2.6 `SearchPage` (`app/lib/ui/search_page.dart`)
- **Purpose**: Search screen with segmented control for Local Library vs. YouTube.
- **Local Search**: Real-time SQLite query matching song title, artist, or lyric content.
- **YouTube Search**: Flat metadata query with channel names and thumbnails. Tapping plays via streaming; download icon saves offline.
- **Search History**: Displays search history chips when query is empty.

---

### 2.7 `DiscoveryPage` (`app/lib/ui/discovery_page.dart`)
- **Purpose**: Stream-first personalized discovery feed.
- **Components**:
  - Candidate cards showing title, artist, provider origin badge (`'Local Library'`, `'Last.fm'`), and calculated score.
  - Stream button (plays directly from YouTube).
  - 10-star rating bar on each card.
  - "Promote" action button (adds candidate to library and initiates local download).

---

### 2.8 `SettingsPage` (`app/lib/ui/settings_page.dart`)
- **Purpose**: Application preferences and data management.
- **Sections**:
  1. **Library**: Folder path selector and "Scan Library" button.
  2. **Spotify CSV Import**: `_ImportSection` utilizing `FilePicker` to import playlist CSVs directly from scratch.
  3. **Playback**: 4-second audio crossfade toggle switch.
  4. **External Providers**: Optional Last.fm API key field. (Qloo was removed.)
  5. **Cover Art**: "Embed art into all files" batch processor and "Clear cover cache" action.

---

## 3. Design System & Theming Tokens

### 3.1 Colors (`app/lib/ui/theme/spotless_colors.dart`)
- **Base Background**: Deep Charcoal / Navy (`#0D1117`).
- **Surface**: Dark Elevated (`#161B22`).
- **Surface Variant**: Light Elevated (`#21262D`).
- **Text Primary**: White (`#F0F6FC`).
- **Text Secondary / Medium**: Medium Gray (`#8B949E`).
- **Text Dim**: Muted Slate (`#484F58`).
- **Accent Primary**: Spotify Green (`#1DB954`).
- **Error**: Soft Red (`#F85149`).
- **Dynamic Gradient**: `SpotlessColors.immersiveGradient(dominantColor)` renders a smooth vertical transition from the album art's dominant color to deep black.

### 3.2 Dynamic Color Extraction (`DynamicThemeProvider`)
- Watches `PlayerController.currentSong`.
- Reads cover image via `CoverService.coverFor(song)`.
- Uses Flutter's `PaletteGenerator.fromImageProvider(FileImage(...), maximumColorCount: 8)` to extract the dominant swatch.
- Generates a dark `ColorScheme.fromSeed(seedColor: dominantColor, brightness: Brightness.dark)`.
- Rebuilds `MaterialApp` theme reactively.

### 3.3 Typography (`app/lib/ui/theme/spotless_typography.dart`)
- Backed by clean modern sans-serif typography (`GoogleFonts.inter` or system fallback).
- **Hero Display**: 38–48sp bold (`displayLarge`).
- **Headlines**: 22–24sp bold (`headlineMedium`).
- **Titles**: 16–18sp semibold (`titleMedium`).
- **Body**: 14sp regular (`bodyMedium`).
- **Captions / Time**: 12sp (`bodySmall`).

### 3.4 Shapes & Corner Radii
- **Standard Cards**: 16dp radius (`SpotlessColors.radiusMd`).
- **Hero Containers & Now Playing Art**: 24dp radius (`SpotlessColors.radiusLg`).
- **Pills & Control Buttons**: Full circle / pill radius 999dp (`SpotlessColors.radiusFull`).
