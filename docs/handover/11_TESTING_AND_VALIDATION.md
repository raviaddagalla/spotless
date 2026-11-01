# 11 — Testing and Validation Suite

> **Document Version**: 1.0.0  
> **Date**: November 1, 2026  
> **Status**: 20 / 20 Automated Tests Passing | Analyzer Clean (0 Errors, 0 Warnings)  

---

## 1. Automated Test Setup

The project uses `flutter_test` with in-memory SQLite databases provided by Drift (`drift/native.dart`: `NativeDatabase.memory()`). Tests execute completely offline without requiring a running Android emulator or external network access.

### Running the Test Suite
```powershell
cd d:\Nandhu\spotify\app
& "C:\Users\aravi\flutter\bin\flutter.bat" test
```

### Static Analysis
```powershell
cd d:\Nandhu\spotify\app
& "C:\Users\aravi\flutter\bin\flutter.bat" analyze
```

---

## 2. Test Coverage Inventory (20 / 20 Passing)

### 2.1 Session Logic Specification §51 (`app/test/session_test.dart`)
- **Test 1**: Continuous activity within 1 hour stays in the same session.
- **Test 2**: Inactivity gap $\ge 1\text{ hour}$ creates a new session and marks previous completed.
- **Test 3**: Application closes 10:30, reopens 10:50 ($<1\text{h}$) $\rightarrow$ Same session.
- **Test 4**: Application closes 10:30, reopens 12:00 ($\ge 1\text{h}$) $\rightarrow$ New session upon activity.
- **Test 5**: Pause 10:30, resume 10:40 ($<1\text{h}$) $\rightarrow$ Same session.
- **Test 6**: Pause 10:30, resume 11:31 ($\ge 1\text{h}$) $\rightarrow$ New session.
- **Test 7**: Backgrounded $<1\text{h}$ $\rightarrow$ Same session when activity resumes.
- **Test 8**: Backgrounded $>1\text{h}$ $\rightarrow$ New session when activity resumes.

### 2.2 Rating System Specification §11–§14 (`app/test/session_test.dart`)
- **Test 9**: Stores 1–10 rating events with history preservation (previous ratings never overwritten).
- **Test 10**: Repeated high ratings across independent sessions increase consistency score.
- **Test 11**: Inconsistent / volatile ratings lower the consistency score.

### 2.3 Implicit Feedback Specification §25 (`app/test/session_test.dart`)
- **Test 12**: Early skips ($<20\%$) penalize score more than late skips ($>80\%$).

### 2.4 Synchronized Lyrics Specification §30–§32 (`app/test/session_test.dart`)
- **Test 13**: LRC parser parses timestamps `[mm:ss.xx]` and extracts plain text.
- **Test 14**: Plain text lyrics parser falls back to unsynchronized correctly when timestamps are absent.

### 2.5 Shuffle & Smart Shuffle Specification §33–§34 (`app/test/shuffle_test.dart`)
- **Test 15**: Normal shuffle keeps current song first and preserves all items without duplicates.
- **Test 16**: Artist diversity spacing avoids consecutive tracks by the same artist.

### 2.6 Local Acoustic Provider & Track Radio Specification §17 & §18 (`app/test/discovery_test.dart`)
- **Test 17**: Calculates 4D acoustic similarity and ranks closer track highest.
- **Test 18**: `discoverSimilarTo` returns scored discovery tracks preserving `existingSong`.
- **Test 19**: `promoteCandidate` marks candidate promoted and persists to `songs` table.
- **Test 20**: `cleanupStaleCandidates` cleans up old entries while keeping promoted entries.

---

## 3. Practical On-Device Regression Checklist

Before shipping any APK to users or committing architectural modifications, execute this manual regression checklist on a physical device:

| Step | Feature | Action | Expected Result | Pass/Fail |
|------|---------|--------|-----------------|-----------|
| 1 | **Local Playback** | Open Library -> Tap downloaded track | Audio starts immediately. Logcat shows `[pos] tick #` every ~4s. | [ ] |
| 2 | **Audio Crossfade** | Let track advance naturally or tap Next | Song B fades in over 4s while Song A fades out. Both audible during overlap. | [ ] |
| 3 | **Wavy Seek Bar** | Drag wavy slider to 01:30 | Audio seeks instantly without buffering stutter; wave animation runs. | [ ] |
| 4 | **Interactive Lyrics** | Tap Lyrics icon in Now Playing | Synced lyrics scroll smoothly. Tapping line 10 seeks audio to that timestamp. | [ ] |
| 5 | **1–10 Star Rating** | Tap star 9 in Now Playing | Star fills; toast confirms rating; `likedAt` timestamp updates in DB. | [ ] |
| 6 | **Track Radio** | Tap sensor icon in toggle row | `SimilarTracksSheet` opens with acoustically similar songs; tapping streams result. | [ ] |
| 7 | **Smart Shuffle** | Cycle shuffle icon to Auto-Awesome | Queue sheet shows "Smart Shuffle Active" pill; tracks spaced by artist. | [ ] |
| 8 | **Local Search** | Search tab -> Local -> query "love" | Instant results across titles, artists, and lyrics. No SQLite errors. | [ ] |
| 9 | **YouTube Streaming** | Search tab -> YouTube -> search song -> tap tile | Song resolves in ~2s and streams over network; Now Playing opens. | [ ] |
| 10 | **YouTube Download** | Tap download icon on YouTube result | Progress indicator moves 0% -> 100%; file lands in `files/spotless/downloads/`. | [ ] |
| 11 | **Embedded Artwork** | Check downloaded file in VLC or external player | High-res cover art appears embedded in the audio file. | [ ] |
| 12 | **Background Media** | Background app and lock screen | Audio continues uninterrupted; notification drawer shows controls and art. | [ ] |
| 13 | **Playlist Reorder** | Open playlist -> drag song #5 to #1 | Position persists immediately upon exit and re-entry. | [ ] |
| 14 | **Playlist Export** | Playlist menu -> "Export .m3u" | Android share sheet opens with generated `.m3u` file containing `#EXTM3U`. | [ ] |
| 15 | **Sleep Timer** | Set timer for 5 minutes or "End of Song" | Playback pauses automatically when timer expires or song finishes. | [ ] |
| 16 | **CSV Import** | Settings -> Import from Spotify -> pick CSV | Progress dialog counts through tracks, downloads, tags, and creates playlist. | [ ] |
| 17 | **Session Continuity** | Pause playback -> wait 10m -> resume | Stays in same session ID. Pause > 60m creates a new session on resume. | [ ] |
