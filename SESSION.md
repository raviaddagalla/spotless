# Spotless — Project Session Notes

Handoff document so a new session can continue without re-discovering the context.

## Problem statement (user's request)

User has ~864 downloaded MP3s (`music/0000001.mp3` …) of their Spotify playlists (plus
`sleep.csv`, `no_sleep.csv` full Spotify playlist exports with rich metadata, `songs.csv`
mapping files → title/artist/youtube_id, `lyrics/` with 605 `.lrc` synced + 75 `.txt`
plain lyric files). They want to stop using Spotify and use a **personal Android app**
that:

1. Plays the local MP3s on the phone.
2. Shows **synced LRC lyrics like Spotify** (plain scrolling text for `.txt` files).
3. Queue / shuffle / normal-order playback.
4. Future-proof: they want to build their own recommendation algorithm later, so all
   Spotify metadata must be stored.

**2026-08-02: STREAMING IS DROPPED** — app is **download-only**: in-app YouTube search +
download → local playback. The "play not-downloaded songs via streaming" requirement is
abandoned (yt-dlp stream extracts worked but ExoPlayer never played googlevideo URLs).

**2026-08-05 (SESSION 3): STREAMING RE-ENABLED.** The "ExoPlayer never played
googlevideo URLs" mystery is SOLVED — it was a code bug (see "The playback bug" below),
not YouTube blocking. YouTube search → tap result → stream is wired up again
(`MusicRepository.resolve()` now calls `yt.extract(...)` for non-downloaded songs).

### Explicit architecture requirements from user (do NOT deviate)
- **Covers**: embedded into the MP3 as ID3 artwork so every player shows the cover.
- **Song Status** enum drives the UI: `downloaded`, `streamable`, `missing`, `failed`,
  `analyzing`.
- **MusicRepository facade**: UI talks ONLY to `MusicRepository`. SQLite, AudioEngine,
  Downloader, RecommendationEngine, Lyrics all sit behind it.

## Key facts about the data (verified)

- `music/` = 864 mp3 files named `0000001.mp3`.. `0000864.mp3`.
- `songs.csv` = 864 rows (`id,filename,title,artist,youtube_id,youtube_title`).
- sleep.csv + no_sleep.csv = 912 rows / 869 unique songs → only **5 playlist songs are
  not downloaded**.
- `lyrics/`: 605 `.lrc` + 75 `.txt`. txt files are valid UTF-8 (Telugu/Tamil/Devanagari);
  app must read UTF-8. Android's Noto fonts render these.
- Playlist CSVs contain track URI, album image URLs, tempo, energy, danceability,
  valence, key, loudness, genres, popularity, added_at, etc. — ALL imported into the DB
  (columns exist on Songs; recommender uses them).
- `download.py` (PC yt-dlp script), `lyrics.py` (lrclib downloader) — reference only.

## Decisions locked with the user

- **Framework**: Flutter (3.44.8). Downloading via **Chaquopy-embedded real yt-dlp**
  (pure-Dart libs are broken in 2026: 403/PO-token).
- **Phone setup**: user USB-copies the folder (music/, lyrics/, songs.csv, sleep.csv,
  no_sleep.csv) to the phone; app scans the chosen folder
  (`/storage/emulated/0/Download/songs_download` on the device).
- **In-app download** → app-private `files/spotless/downloads/`.
- App name: **Spotless** (package `com.nandhu.spotless`).

## Environment (set up)

- Flutter **3.44.8** at `C:\Users\aravi\flutter` — NOT on PATH; use
  `C:\Users\aravi\flutter\bin\flutter.bat` (PowerShell: `&` call operator).
- Android SDK `C:\Users\aravi\AppData\Local\Android\Sdk`, Java 17 (Adoptium),
  Python 3.13 at `C:\Users\aravi\AppData\Local\Programs\Python\Python313\python.exe`
  (Chaquopy buildPython).
- Device: **NARZO 70 Pro 5G (Realme RMX3868)** — serial `AENVTKIFUSCY5TT4`. It dropped
  off adb once this session; `adb kill-server; adb start-server` reconnects it.

## Build/install workflow (IMPORTANT — current, verified)

- Build: `& C:\Users\aravi\flutter\bin\flutter.bat build apk --debug`
- Install: **`adb install -r -t` FAILED again with `INSTALL_FAILED_VERIFICATION_FAILURE`
  (session 2)**. Use the push+pm workaround:
  `adb push app\build\app\outputs\flutter-apk\app-debug.apk /data/local/tmp/; adb shell pm install -r -t /data/local/tmp/app-debug.apk` — works.
- After install: `adb logcat -G 16M` (tiny default buffer), then launch with
  `adb shell monkey -p com.nandhu.spotless -c android.intent.category.LAUNCHER 1`.
- DB pull (PowerShell corrupts binary redirects — use `cmd /c`):
  `cmd /c "adb exec-out run-as com.nandhu.spotless cat app_flutter/spotless.sqlite > out.sqlite"`
- Inline `python -c` fails on PowerShell quoting — write scripts to
  `C:\Users\aravi\AppData\Local\Temp\opencode\` and run them.
- **THIS MODEL CANNOT READ SCREENSHOTS** (no image input) — verify by logcat + DB
  pulls, and ask the user what they see on screen.
- OPPO/Realme `InstallFinishActivity` overlay can cover the screen after install and
  eat taps — dismiss with back key before UI automation.
- **User drives UI interaction** (types/taps in the app): wait for the user to perform
  actions and report; read logs/DB afterwards. Don't automate taps while the user tests.

## Project layout (D:\Nandhu\spotify\app)

```
lib/
  main.dart                      <- engine/repo init, MultiProvider, crossfade pref applied
  core/
    models/song_status.dart, models/lyrics.dart
    db/tables.dart               <- Songs, LyricsTable, Playlists, PlaylistSongs
    db/app_database.dart, app_database.g.dart
    csv/csv_parser.dart, lyrics/lrc_parser.dart
    youtube/yt_bridge.dart       <- MethodChannel wrapper
    services/library_scanner.dart, cover_service.dart, downloader.dart,
             recommender.dart, music_repository.dart (facade)
    audio/audio_engine.dart      <- just_audio + audio_service + CROSSFADE (aux player)
    state/player_controller.dart <- ChangeNotifier + sleep timer + reorder
  ui/
    home_shell.dart, home_page.dart (horizontal card rows), library_page.dart,
    search_page.dart (Local/YouTube + history), now_playing_page.dart,
    playlists_page.dart (export .m3u), playlist_songs_page.dart, liked_songs_page.dart,
    playlist_page.dart (sleep/no_sleep legacy), lyrics_page.dart, settings_page.dart,
    artists_page.dart, artist_detail_page.dart, albums_page.dart, album_detail_page.dart,
    widgets/{album_art,status_badge,song_tile,song_card,slidable_song_tile,
             mini_player,synced_lyrics_view,playlist_picker}.dart
android/
  app/src/main/kotlin/com/nandhu/spotless/MainActivity.kt   <- MethodChannel bridge
  app/src/main/python/ytdlp.py                              <- yt-dlp/mutagen module
  app/src/main/AndroidManifest.xml                          <- permissions + audio_service
  settings.gradle.kts / app/build.gradle.kts                <- chaquopy 17.0.0 block
```

## Status — CURRENT (2026-08-05, SESSION 4 — CODE DONE, INSTALLED, USER TESTING)

Session 4: user reported streaming broken + local search broken + slow YouTube
search, asked for auto lyrics/cover after download, then (after everything was
fixed and user confirmed "everything works!!!!!") asked for a CSV-only import
feature + a smaller shareable APK. All code done, built, INSTALLED on device
(debug), user is testing. See "Remaining work".

### Bug 4 — local search broken (FIXED, in session-4 build)
- Symptom: any local search → `Invalid argument (statement): Must return
  exactly one column (actually returns 3): Instance of
  'SimpleSelectStatement<$LyricsTableTable, LyricsTableData...`.
- Cause: `searchSongs()` passed a `db.select(db.lyricsTable)` (ALL 3 columns)
  into `t.id.isInQuery(...)`, which requires a 1-column subquery.
- Fix (music_repository.dart): `db.selectOnly(db.lyricsTable)
  ..addColumns([db.lyricsTable.songId])` and note drift 2.34.3's
  `JoinedSelectStatement.where` takes `Expression<bool>` DIRECTLY, not a
  callback (the old-style `..where((l) => ...)` doesn't compile there).

### Bug 5 — streaming broken: storyboard pick + dead android client (FIXED)
- Root cause (verified by benchmarking the SAME yt-dlp 2026.7.4 the app
  pins, on PC): YouTube's "android" player client now returns ONLY storyboard
  thumbnails (ext mhtml / acodec none / proto mhtml) + muxed format 18, NO
  audio-only formats. `_pick_audio()`'s naive filter (`vcodec none`)
  happily picked a storyboard URL → ExoPlayer had nothing to play →
  "streaming is not working".
- Clients that DO return real audio-only (verified): `android_vr`,
  `tv_embedded`, `android_creator` (formats 139/249/140/251, m4a+opus);
  `tv` → "DRM protected" on some videos; mweb/web/web_embedded/web_safari →
  no formats.
- Fixes in ytdlp.py:
  1. `player_client: ["android_vr", "tv_embedded", "android_creator", "ios"]`
  2. `_pick_audio()` now also requires `acodec not in (None,"none")` and
     `ext not in (None,"unknown","mhtml")` — storyboards excluded.
  3. `extract()` no longer sets `format:` — _pick_audio selects from the raw
     list itself, so yt-dlp can't throw "Requested format is not available".

### YouTube search — 9x faster (FIXED)
- Cause: `ytsearch15:` did full per-video extraction (~18s for 10 results).
- Fix: `opts["extract_flat"] = "in_playlist"` → search page metadata only
  (~2s for 15 results, measured). Flat entries have `thumbnails[]` list but
  no top-level `thumbnail` → take `thumbs[-1]["url"]`, else construct
  `https://i.ytimg.com/vi/<id>/mqdefault.jpg`. duration/channel present.

### Auto lyrics + cover after download (session-4)
- `fetch_lyrics(title, artist)` added to ytdlp.py (stdlib urllib only, no new
  pip deps): tries lrclib `/api/get?track_name=&artist_name=` (exact match,
  404 when absent) then `/api/search?q=` fallback. Returns
  `{lyrics, is_synced}`.
- Kotlin channel: `fetch_lyrics` case added; YtBridge `fetchLyrics()` added.
- `_finalizeDownload()` now stores lyrics into LyricsTable (type 'lrc' when
  is_synced else 'txt') after every download.
- Search-page `_toSong()` now sets `albumArtUrl` from the YouTube thumbnail so
  cover embed works for downloaded search results.

## SESSION 4 — NEW FEATURE: CSV-only playlist import (Settings → Import from Spotify)

Users can hand over Spotify playlist export CSVs (no local music folder, no
songs.csv needed). Each CSV becomes a playlist; every song is found on
YouTube, downloaded, tagged, given lyrics + embedded cover automatically.

- `MusicRepository.importPlaylistCsvs(paths, {onProgress})` →
  `({total, imported, skipped, failed})`:
  - Parses each file with CsvParser; header aliases (case-insensitive):
    title: Track Name/Song Title/Title/Name; artist: Artist Name(s)/Artist/
    Artist Name/Artists; uri: Track URI/URI; album art: Album Image URL/...
    thumbnail; duration ms: Track Duration (ms)/...; youtube_id: youtube_id/
    Video ID; added: Added At/Date Added.
  - Song id = Track URI (dedupes across CSVs), else `imp:<playlistId>:<i>`.
  - Upserts songs row (status `analyzing`), links into playlist, then
    `downloadSong()`; skips songs whose localPath exists (resume-safe);
    marks failed songs status `failed` + error text.
  - `downloadSong()` fallback query (no youtubeId) is now
    `ytsearch1:<title> <artist> official audio` (was a bare query that
    yt-dlp would reject). `download()` in ytdlp.py unwraps ytsearch
    entries and returns `id` + `thumbnail`; `_finalizeDownload` stores
    youtubeId/resolvedYtTitle and albumArtUrl-from-thumbnail when missing.
- Settings UI: `_ImportSection` — `FilePicker.pickFiles(allowMultiple,
  allowedExtensions: ['csv'])` → reuses `_ProgressDialog` → summary SnackBar
  (imported / already downloaded / failed).
- NOTE: sequential downloads (single Kotlin executor). 800+ songs = hours;
  the per-song progress dialog updates between downloads. Re-run resumes.

## APK size for sharing (session 4)

- Debug APK (installed on device): **187MB** — debug symbols + both ABIs.
- `flutter build apk --release` (arm64 + x86_64): **80.1MB**.
- `flutter build apk --release --target-platform android-arm64`: **59.1MB**
  → copied to `D:\Nandhu\spotify\apk\spotless-arm64-v8a-release.apk`.
  This is the one to share (works on all modern phones; arm64-only).
- `--split-per-abi` CONFLICTS with the `ndk { abiFilters }` block in
  build.gradle.kts (arm64-v8a, x86_64) — don't use it.
- Release is signed with the debug keystore (build.gradle.kts) → installable
  via side-loading, NOT Play-Store-publishable.

### On-device state RIGHT NOW (end of session 4)
- Debug build with all session-4 fixes INSTALLED + launched, no crash.
- User has NOT yet tested: CSV import feature, search fix, streaming fix,
  search speed, auto lyrics/cover. Old data intact (install was `-r`).

## Device-verification checklist (NEXT SESSION — resume from here)

1. **Local search**: Search tab → Local → any query (title/artist/lyrics) →
   results must return (no 1-column/3-column error).
2. **Streaming (Bug 5)**: YouTube tab → query → tap result → audio plays;
   also Library → a `streamable` song. If it still fails, check
   `adb logcat -s ytdlp` + `ytdlp_debug.log` (run-as) — expect googlevideo
   URL with ext webm/m4a, NOT mhtml.
3. **Search speed**: YouTube search should return in ~2-4s (was ~18s+).
4. **Auto lyrics/cover**: download a YouTube search result → Now Playing must
   show fetched lyrics (lrclib) + cover (YouTube thumbnail embedded).
5. **CSV import (NEW)**: Settings → Import from Spotify → pick 1-2 CSVs →
   per-song progress; playlists appear with downloaded songs; re-run resumes.
   Expect hours for full 864-song playlists.
6. **Release APK**: optionally `pm install -r -t` the 59MB release APK over
   the debug install (same debug signature, data preserved) to verify the
   build friends will get.

## Gotchas discovered in session 4 (add to the old list)

- **drift 2.34.3 `selectOnly().where()` takes `Expression<bool>` directly**
  (not a callback like `select().where`).
- **yt-dlp 2026.7.4 + android client = storyboards only** — never trust the
  android client for audio; android_vr/tv_embedded/android_creator work.
- **`extract_flat: "in_playlist"`** makes ytsearch ~9x faster but drops the
  top-level thumbnail (use `thumbnails[-1]["url"]` or i.ytimg.com fallback).
- **`--split-per-abi` + `ndk.abiFilters` conflict** — use
  `--target-platform android-arm64` instead (59MB vs 187MB debug).
- Device dropped off adb again mid-session; `adb kill-server;
  adb start-server` + wait reconnected it.



Session 3 was: fix the 3 confirmed bugs + a playback bug found on-device, build,
install, and regression-test. **All code fixes are done, built, and INSTALLED on the
phone. Local playback verified working on-device. Streaming NOT yet verified**
(app was stopped mid-test by user request — the phone currently has the app open on a
song's lyric/Now Playing page, "Past Lives" was playing).

### The playback bug (session 3) — CRITICAL FINDING, FIXED, VERIFIED
- Symptom: tapping a song → "Playback failed: (0) Source error". Logcat showed
  `ExoPlayerImplInternal: Cleartext HTTP traffic to 127.0.0.1 not permitted`.
- Root cause: **just_audio routes ANY UriAudioSource with a non-null headers map
  (even an empty one) through its localhost proxy** (`_ProxyHttpServer` on
  127.0.0.1, just_audio.dart `_onLoad` ~line 2746). Our engine always passed
  `headers:` (even `{}` for local files) and local paths were schemeless
  (`/storage/...`) which is NOT `scheme == 'file'` → proxied → ExoPlayer did
  cleartext HTTP to 127.0.0.1 → blocked by default on API 28+ → Source error.
  **This is ALSO the real reason session 2's streaming "never played": every
  googlevideo URL + headers went through the same proxy. It was never YouTube
  blocking — it was this code bug.**
- Fix (2 parts, both required):
  1. `audio_engine.dart` new `_sourceFor()`: local paths (no scheme or `file:`)
     → `Uri.file(path)` with `headers: null` (no proxy). Remote/stream URLs keep
     their extracted headers and go through the proxy.
  2. `android/app/src/main/res/xml/network_security_config.xml` (NEW) + manifest
     `android:networkSecurityConfig="@xml/network_security_config"`: permits
     cleartext ONLY to 127.0.0.1/localhost so the proxy works for streams.
- VERIFIED ON DEVICE: tapping "Past Lives" (0000007) in Library → ExoPlayer init →
  `[pos] tick #20 = 0:00:03.37` → tick #40 = 0:00:07.37 (200ms ticker running,
  audio playing).  USER confirmed the earlier failure; after this fix the song
  played. (User said "I can hear..." — no wait, user confirmed errors before;
  after fix, logs show clean playback. Ask user to confirm sound.)

### Bug 1 — streaming silently disabled — FIXED (code done, NOT device-verified yet)
- `resolve()` in music_repository.dart now: local file → local source; else if
  song has a youtubeId → `yt.extract('https://www.youtube.com/watch?v=<id>')` →
  returns `ResolvedPlayable(url, isStream: true, status: streamable, headers:
  extracted http_headers)` (headers REQUIRED — see proxy bug above). Throws on
  extract failure so errors surface. Missing (no youtubeId) songs still resolve
  empty → visible error.
- `search_page.dart` YouTube tiles: onTap now plays via `player.playQueue([song])`
  + opens NowPlaying (snackbar "Not downloaded yet" removed). Download icon button
  stays for offline saving. Idle hint text updated.
- `player_controller.dart._resolveUri` error text updated.
- Retry-on-expiry hardening in `audio_engine.dart`: `_startSourceOn()` re-resolves
  once after a cached URL fails; `_onProcessingState` treats unexpected `idle`
  while `_activePlayback` as a stream failure → drops cache entry, fires
  `onLoadError` (controller shows error + skips to next). `_activePlayback` flag
  set on successful load, cleared in stop()/completion/before `old.stop()` in
  `_runCrossfade`.

### Bug 2 — migration raw date literal — FIXED (code done, v1→v2 path NOT device-verified)
- OLD build's DB had `created_at = '2026-01-01'` **text** (confirmed by pulling the
  old DB: `typeof(created_at) = 'text'`) — drift reads DateTime as unix-epoch
  INTEGER with NativeDatabase, so parsing those rows throws → PlaylistsPage errors.
- FIX in app_database.dart onUpgrade: typed inserts via `db.into(db.playlists)
  .insert(PlaylistsCompanion.insert(...))` with real `DateTime(2026,1,1)` (capture
  `final db = this;` — `m.database` is only `GeneratedDatabase`). playlist_songs
  raw INSERT...SELECTs kept (plain ints/text, fine).

### Bug 3 — addToPlaylist silently drops not-downloaded songs — FIXED (code done, NOT device-verified)
- `addToPlaylist(String playlistId, SongRow song)` now takes the full SongRow,
  upserts a stub `songs` row (status `streamable`, `InsertMode.insertOrIgnore`)
  when the song isn't in the library, then inserts the playlist_songs row.
  `playlist_picker.dart` caller updated. Without this, the inner join in
  `playlistSongRows()` had no `songs` row to match → song vanished silently.

### Build state
- `flutter analyze` CLEAN (last run after all fixes).
- `flutter build apk --debug` builds in ~150s (incremental) — the installed APK is
  the one with ALL session-3 fixes.
- Fresh-install path VERIFIED: app opens to Home (empty library), no StartupError.
- v1→v2 migration path NOT yet exercised on device (see "Remaining work").

### On-device state RIGHT NOW (2026-08-05 ~20:40)
- App installed (build with all fixes), library SCANNED (user granted All files
  access after earlier permission denial), 864 songs in DB, Home shows Recently
  played/Playlists(Sleep 580/No Sleep 289)/For you. "Past Lives" was playing.
- NOTE: user uninstalled the session-2 app mid-session; current install is
  FRESH (no sleep/no_sleep playlists in DB until a v1→v2 migration happens —
  fresh install has EMPTY playlists; the legacy playlists only come from the
  v1→v2 migration path which needs testing with a v1 DB — see Remaining work).

## Device-verification checklist (NEXT SESSION — resume from here)

1. **YouTube streaming (Bug 1)**: Search tab → YouTube segment → query → tap a
   result → audio must play. Check `adb logcat -s ytdlp` + `ytdlp_debug.log`
   (app-private, `run-as` or the debug log) if it fails. Also test streaming an
   already-scanned song with status `streamable` (youtube_id present) from Library.
2. **v1→v2 migration (Bug 2)**: craft a v1 DB (drop playlists/playlist_songs
   tables + liked_at column, set `PRAGMA user_version=1`), push into app dir,
   relaunch → migration runs → PlaylistsPage must load, Sleep/No Sleep seeded
   with 580/289 songs, `created_at` now INTEGER (verify with `typeof()`).
3. **Bug 3**: YouTube search result → add to a playlist WITHOUT downloading →
   open playlist → song must be there.
4. **YouTube download**: search → download icon → file lands in app-private
   downloads, DB row status `downloaded`, plays back locally, progress %
   actually moves (not instant 100%).
5. Full F1–F12 regression (queue reorder, sleep timer, crossfade audio overlap,
   mini-player swipe, slidable actions, liked songs, artists/albums, playlist
   export .m3u via share sheet, search history, offline-only chip, settings).
6. `flutter analyze` clean before any build; keep it that way.

## Gotchas discovered in session 3 (add to the old list)

- **just_audio proxy**: non-null headers map on `AudioSource.uri` (even `{}`) →
  localhost proxy → cleartext blocked → "Source error (0)". Local files MUST go
  through `_sourceFor()` with `headers: null` + `Uri.file`.
- **`run-as` now says "package not debuggable"** after `pm install -r -t` — the
  earlier session-2 install DID allow run-as DB pulls. If run-as fails again,
  verify with `adb shell dumpsys package com.nandhu.spotless | grep -i debug` and
  try `adb install -r -t` instead of pm install; DB pulls are essential for
  verification. (First pull after fresh install DID work via
  `cmd /c "adb exec-out run-as ... cat app_flutter/spotless.sqlite > out.sqlite"`.)
- **User's library is on the phone at `/storage/emulated/0/Download/songs_download`
  (verified: music/ 864 mp3s + lyrics/ + songs.csv + sleep.csv + no_sleep.csv).**
  All-files access (MANAGE_EXTERNAL_STORAGE) is a REQUIREMENT — without it the
  scan throws `Permission denied` on songs.csv. Grant via Settings → Special
  access; app doesn't request it itself.
- App reads the library fine once permission is granted (scan is a full wipe+
  re-import of songs/lyrics tables).
- Device is NARZO 70 Pro 5G, serial AENVTKIFUSCY5TT4; `adb kill-server;
  adb start-server` if it drops.
- OPPO/Realme InstallFinishActivity overlay: press BACK before driving UI after
  installs. Dismissed already this session.

1. **F1 Real playlists + Liked Songs** — CODED + migration verified on device; playlist
   create/add/remove, like/unlike, Library layout NOT yet exercised by user.
   - Schema: `likedAt` on Songs; `Playlists(id,name,createdAt)`; `PlaylistSongs` PK
     {playlistId,songId}; v1→v2 `onUpgrade` seeds sleep/no_sleep via customStatement.
   - Repo: playlists/playlistSongs/playlistSongRows/createPlaylist/renamePlaylist/
     deletePlaylist/addToPlaylist (idempotent, position=length)/removeFromPlaylist/
     likedSongs/isLiked/setLiked.
   - UI: playlists_page (create/rename/delete/export), playlist_songs_page (play queue,
     remove), liked_songs_page, playlist_picker bottom sheet, Library action cards,
     NowPlaying `_LikeButton`.
2. **F2 Slider swipes — DONE** `widgets/slidable_song_tile.dart`: Slidable wrapping
   SongTile; swipe right = Download (start pane, only when not downloaded); swipe left =
   Playlist / Like/Unlike / Next (end pane). Used in Library, LikedSongs,
   PlaylistSongs, ArtistDetail, AlbumDetail.
3. **F3 Liked Songs UI — DONE** (page + slidable).
4. **F4 Reorderable queue — DONE** `PlayerController.moveQueueItem(from,to)` (fixes
   `_current`, regenerates shuffle keepFirst:current); QueueSheet is now
   `ReorderableListView.builder` with `ReorderableDragStartListener` handles.
   **Flutter 3.44: `onReorder` is deprecated → use `onReorderItem`** (newIndex already
   adjusted; do NOT decrement it).
5. **F5 Home sections — DONE** horizontal card rows (`widgets/song_card.dart`,
   `_SongCardRow` in home_page) for Recently played + For you; Sleep/No Sleep cards stay.
6. **F6 Search history — DONE** repo `searchHistory/addSearchHistory` (key
   `search_history`, cap 10)/`clearSearchHistory`; SearchPage idle state shows
   `_SearchIdle` history chips + Clear. Queries are recorded on every search (both modes).
7. **F7 Crossfade — DONE (see BUG section above)** `engine.setCrossfade(Duration)`
   (zero = off, default 4s); `_crossfadeTo`/`_runCrossfade`/`_fadeVolume` (16 steps);
   Settings → Playback SwitchListTile (pref key `crossfade`); applied at startup in
   main.dart; `PlayerController.setCrossfade`.
8. **F8 Sleep timer — DONE** PlayerController: `startSleepTimer(d)` (Timer + 1s tick),
   `startSleepAfterCurrent()` (pause when next song starts, in `_onSongChanged`),
   `cancelSleepTimer`, `sleepRemaining`, `sleepTimerActive`. NowPlaying AppBar
   `_SleepTimerButton` (countdown badge) → bottom sheet: 5/10/15/30/60 min, End of
   current song, Turn off timer.
9. **F9 Offline filter — DONE** pref key `offline_only`; Library `FilterChip` "Offline"
   in the status bar; `watchSongs({status, offlineOnly})` and
   `searchSongs(q, {offlineOnly})` force status==downloaded; local Search respects it.
10. **F10 Artists/Albums — DONE** repo `artists()/albums()/songsByArtist/songsByAlbum`
    (selectOnly + groupBy); Library now has 4 action cards (Playlists, Liked, Artists,
    Albums); pages: artists_page → artist_detail_page (album headers + Play all +
    Shuffle), albums_page → album_detail_page (art header + Play/Shuffle + list).
11. **F11 Mini-player swipe — DONE** GestureDetector onHorizontalDragEnd around the
    MiniPlayer: |velocity| ≥ 300 px/s → left: next(), right: previous(); tap still
    opens NowPlaying.
12. **F12 Playlist export — DONE** repo `exportPlaylist(id)` writes
    `spotless/exports/<name>.m3u` (EXTM3U + EXTINF + localPath-or-title); PlaylistsPage
    ⋮ menu "Export .m3u" → **share_plus 11: static `Share.shareXFiles` is DEPRECATED —
    use `SharePlus.instance.share(ShareParams(files: [XFile(...)], subject:, text:))`**.

## Device-verification checklist (NEXT SESSION, first task)

1. Play a downloaded song → confirm sound + `[pos] tick #` in logcat (proves the
   ticker/playback runs) → **this also proves the crossfade fix**.
2. Crossfade: let a queue advance naturally / tap next → second song should start
   ~immediately (overlapping) and fade in over 4s; both players audible during overlap.
3. Swipe left/right on Library rows (F2), Offline chip (F9), 4 action cards (F10),
   Artists/Albums detail pages + Play all/Shuffle.
4. Playlists: create/rename/delete/add/remove songs, Export .m3u → share sheet (F1/F12).
5. Queue sheet: drag handles reorder, remove, jump (F4).
6. Search: recent history chips before searching; local results play (F6).
7. Sleep timer: badge countdown; End-of-song pauses at next track (F8).
8. Mini-player swipe skip (F11).
9. Settings → Playback crossfade toggle off/on (F7).

## MethodChannel contract (`spotless/ytdlp` → Python `ytdlp.py`)

- `extract(query)` → {id,title,duration,thumbnail,url,ext,abr}
- `search(query, max_results)` → list of {id,title,duration,thumbnail,channel}
- `download(url, outdir, base_name)` → {path,ext,title,duration}; progress →
  `$HOME/ytdlp_progress.txt` ("pct|done|total")
- `embedCover(path, image_bytes, mime)` → bool; `setTags(path, title, artist)` → bool;
  `probe(path)` → {duration}; `getProgress()` → string
- All returns JSON-string encoded (`json.dumps(ensure_ascii=False, default=str)`);
  Kotlin: `result.success(py.toString())`; Dart: `jsonDecode`. 90s timeout via
  `future.get(90, SECONDS)`. Durable log `files/ytdlp_debug.log`.

## DB schema (drift, version 2)

`Songs`: id (PK, "0000001" | "yt:<videoId>"), filename, title, artist, album, youtubeId,
localPath, status (SongStatus.name), durationMs, albumArtUrl, albumArtPath, artEmbedded,
trackUri, isrc, trackNumber, explicit, popularity, genres, danceability, energy, key,
loudness, mode, speechiness, acousticness, instrumentalness, liveness, valence, tempo,
timeSignature, addedAt, sleepOrder, noSleepOrder, lastPlayedAt, playCount, likedAt,
resolvedYtTitle, error.
`LyricsTable`: songId (PK), type ('lrc'|'txt'), content.
`Playlists`: id (PK, 'sleep'|'no_sleep'|'pl_<ts>'), name, createdAt.
`PlaylistSongs`: playlistId, songId, position — PK{playlistId,songId}.

## Implementation notes

### MusicRepository (facade) API
- `init()`: app support dir, spotless/{covers,downloads}, library_root pref.
- Prefs: `offlineOnly()/setOfflineOnly` (offline_only), `crossfadeEnabled()/set...`
  (crossfade), `searchHistory()/addSearchHistory/clearSearchHistory` (search_history).
- Queries: `watchSongs({status, offlineOnly})` (CSV-added order), `allSongs`,
  `playlist('sleep'|'no_sleep')`, `recent()`, `mostPlayed()`, `lyricsFor(song)`,
  `searchSongs(q, {offlineOnly})`, playlists/liked APIs, `artists()/albums()/
  songsByArtist/songsByAlbum`, `exportPlaylist(id)`.
- `resolve(song)` → local-only; `recordPlay`, `downloadSong` (yt-dlp → app dir,
  setTags, probe, status→downloaded, embed cover), `_finalizeDownload` upserts,
  `coverFor`/`embedCover`/`embedAllCovers`, `clearCoverCache`, `forYou`/`similarTo`,
  `searchYoutube`.

### AudioEngine (just_audio 0.10.6 + audio_service 0.18.19)
- `setQueue(items, {startAt, order, autoPlay, reload})`; shuffle via `order`; repeat
  off/all/one; lazy resolution via `resolver(queueIndex)`.
- **Crossfade**: `_player`/`_aux` (both non-final AudioPlayers), `_attach(p)`/
  `_detach()` manage the 3 subscriptions (`playbackEventStream`→`_transformEvent`,
  `playerStateStream`→ticker, `processingStateStream`→completion). `_runCrossfade`:
  resolve → `_aux.setAudioSource` → `_aux.setVolume(0)` → **`unawaited(_aux.play())`**
  → `Future.wait` of two `_fadeVolume` (16 steps, 1→0 and 0→1) → pause-next-if-user-
  paused → `old.stop()` → swap refs → `_attach` → `mediaItem.add` + `onSongChanged`.
  `_ensureIdle()` serializes transitions. `setCrossfade(Duration)` (zero=off).
- Live position: ~200ms ticker publishing `playbackState.copyWith(updatePosition)`.
- Notification via `mediaItem.add()`, `queue.add()`, playbackState from
  `playbackEventStream`.

### PlayerController
- `_queue`, `_shuffleOrder` (keepFirst:current), repeat/shuffle, position/duration,
  currentLyrics, download progress. Methods: playQueue/playSong/addNext/addToQueue/
  removeAt/**moveQueueItem**/setShuffle/setRepeat/setCrossfade/next/previous/seek/
  jumpTo/stop/downloadCurrent/downloadSong.
- Sleep timer: `startSleepTimer/startSleepAfterCurrent/cancelSleepTimer/sleepRemaining/
  sleepTimerActive`; `_onSongChanged` honors end-of-song; dispose cancels timers.

### UI screens
- HomeShell: IndexedStack + NavigationBar + MiniPlayer; settings AppBar action.
- Home: Recently played (horizontal cards), Sleep/No Sleep cards, For you (cards).
- Library: 4 action cards (Playlists/Liked/Artists/Albums) + status chips + Offline
  chip + watchSongs stream + slidable rows with 3-dot menu.
- SearchPage: Local/YouTube SegmentedButton; idle → history chips; local results
  playable; YouTube → download-only; initialQuery support.
- NowPlaying: big art, seekbar, controls, Download (missing), _LikeButton, Queue sheet
  (reorder/jump/remove), Lyrics, sleep timer button.
- SettingsPage: Library path + Browse + Save & Rescan, Playback (crossfade), Covers.

## Gotchas / notes for next session

- PowerShell 5.1: no `&&`; use `; if ($?) { }`. Flutter not on PATH.
- **`SongRow`/`Playlist`/`PlaylistSong` live in `app_database.dart` library** — import
  `../core/db/app_database.dart`. Generated names: `db.playlists`, `db.playlistSongs`,
  `db.lyricsTable` (NOT `db.lyrics`).
- drift 2.34: companions take `Value<T>`; no `nullsLast` → `OrderingTerm.asc(t.col.isNull())`.
- **just_audio `play()` blocks until pause/stop/complete — NEVER await it in
  transitions.** (This cost the whole F2–F12 verification session.)
- **Flutter 3.44 `ReorderableListView.onReorder` is deprecated → `onReorderItem`**
  (newIndex already adjusted).
- **share_plus 11: `Share.shareXFiles` deprecated → `SharePlus.instance.share(
  ShareParams(files:..., subject:, text:))`.**
- Kotlin bridge: submit with explicit `java.util.concurrent.Callable<PyObject>`; guard null.
- audio_service: manifest service/receiver MANDATORY + `AudioServiceActivity`.
  BehaviorSubjects (`.add()`); `MediaItem` has no `uri`.
- Chaquopy 17.0.0: AGP 7.3–9.2 OK (pin 8.13.0), minSdk ≥ 24, Python 3.13 64-bit-only
  ABIs. No ffmpeg postprocessing (keep m4a/opus/webm).
- yt-dlp unpinned in pip block; bump/repin to fix YouTube breakage.
- file_picker 11: static `FilePicker.getDirectoryPath(...)`.
- `flutter analyze` must be clean before builds; run build_runner after table changes.
- Stream URL headers (from `http_headers`) are dead code now — harmless.
- Screenshot binary redirects must go through `cmd /c` (PowerShell corrupts).

## Remaining work (todo)

1. **Verify the crossfade fix + F1–F12 on device** (checklist above): first step is tap
   a song and confirm audio + `[pos] tick` logs.
2. If anything misbehaves, fix; keep `flutter analyze` clean.
3. Update SESSION.md at end of every session.
