# 06 — External Services and API Integrations

> **Document Version**: 1.0.0  
> **Date**: November 1, 2026  
> **Security Notice**: No real API keys, secrets, or tokens are stored in this document or in the repository.  

---

## 1. External Integrations Inventory

| Service / API | Purpose | Required Secrets | Auth Location | Network Required | Fallback Mechanism |
|---------------|---------|------------------|---------------|------------------|--------------------|
| **YouTube (via embedded yt-dlp)** | Audio stream extraction, video search, canonical studio matching, downloading | None (uses public YouTube endpoints) | None required | Yes (for search/stream/download) | Offline playback from local library |
| **LRCLIB (lrclib.net)** | Synchronized (`.lrc`) and plain text lyrics retrieval | None (Public open API) | User-Agent header (`Spotless/1.0`) | Yes (during download or lyrics fetch) | Local cached lyrics or plain text fallback |
| **Last.fm Web Services** | Track similarity (`track.getSimilar`) and artist recommendations | Last.fm API Key | Settings UI (`_lastFmKeyPref`) | Yes | `LocalMetadataProvider` (offline acoustic Euclidean matching) |
| **Qloo Taste API** | Cultural & cross-domain taste similarity | Qloo API Key | Settings UI (`_qlooKeyPref`) | Yes | `LocalMetadataProvider` |
| **Spotify Cover CDN** | Album artwork downloading for pre-seeded tracks | None (Public image URLs from CSV) | None | Yes | YouTube video thumbnails or default placeholder |
| **Localhost Audio Proxy** | ExoPlayer streaming bridge | None (Internal loopback `127.0.0.1`) | `network_security_config.xml` | Local loopback only | Direct file URI for local playback |

---

## 2. Integration Deep-Dives

### 2.1 YouTube Integration (via Chaquopy & `yt-dlp`)
- **Source Files**:
  - [app/android/app/src/main/python/ytdlp.py](file:///d:/Nandhu/spotify/app/android/app/src/main/python/ytdlp.py)
  - [app/android/app/src/main/kotlin/com/nandhu/spotless/MainActivity.kt](file:///d:/Nandhu/spotify/app/android/app/src/main/kotlin/com/nandhu/spotless/MainActivity.kt)
  - [app/lib/core/youtube/yt_bridge.dart](file:///d:/Nandhu/spotify/app/lib/core/youtube/yt_bridge.dart)
- **Engine**: Python library `yt-dlp` (pinned at `2026.7.4` in `app/android/app/build.gradle.kts`).
- **Endpoints Accessed**: Standard YouTube public player endpoints (`https://www.youtube.com/watch?v=...`, `https://www.youtube.com/results?search_query=...`).
- **Player Clients**:
  ```python
  "player_client": ["android_vr", "tv_embedded", "android_creator", "ios"]
  ```
  *Note*: Essential to avoid YouTube's 2026 storyboard-only behavior on the default Android client.
- **Rate Limits & IP Blocks**: YouTube occasionally rate-limits or challenges IP addresses with PO-tokens (Proof of Origin). `yt-dlp` updates regularly; if YouTube breaks, update `yt-dlp` version in `build.gradle.kts`.
- **Failure Modes**:
  - `HTTP 403 Forbidden`: Stream URL expired. `AudioEngine` drops cached URL and re-resolves.
  - Video unavailable/private: Surfaced as `StateError` to Flutter and displayed in UI.

---

### 2.2 LRCLIB Lyrics API (`lrclib.net`)
- **Source Files**:
  - [app/android/app/src/main/python/ytdlp.py](file:///d:/Nandhu/spotify/app/android/app/src/main/python/ytdlp.py): `fetch_lyrics()`
- **Endpoints**:
  1. **Exact Match**: `https://lrclib.net/api/get?track_name=<title>&artist_name=<artist>&album_name=<album>&duration=<seconds>`
  2. **Fuzzy Fallback**: `https://lrclib.net/api/search?q=<artist>+<title>`
- **Authentication**: Free public API. Requires a valid `User-Agent` header (`Spotless/1.0`).
- **Priority Logic**:
  - Always prefers `syncedLyrics` over `plainLyrics`.
  - When fuzzy search is used, candidates are sorted by duration distance relative to the known recording duration.
- **Failure Modes**: Returns HTTP 404 if no lyrics exist. Handled cleanly with `{lyrics: null, is_synced: false}`.

---

### 2.3 Last.fm Web Services API
- **Source Files**:
  - [app/lib/core/services/lastfm_provider.dart](file:///d:/Nandhu/spotify/app/lib/core/services/lastfm_provider.dart)
- **Base Endpoint**: `https://ws.audioscrobbler.com/2.0/`
- **Methods Used**:
  - `method=track.getsimilar`
- **Configuration**:
  - Key entered by user in **Settings Page** under "External Discovery Providers".
  - Stored in `SharedPreferences` under key `last_fm_api_key`.
  - Never hardcoded in the codebase.
- **Request Format**:
  ```
  GET https://ws.audioscrobbler.com/2.0/?method=track.getsimilar&artist=<artist>&track=<title>&api_key=<API_KEY>&format=json&limit=15&autocorrect=1
  ```
- **Timeout**: 15 seconds (`AppConfig.providerTimeout`).
- **Fallback**: If unconfigured (`apiKey == null`), `LastFmProvider.isConfigured` returns `false`, and `DiscoveryService` skips it without errors, falling back to `LocalMetadataProvider`.

---

### 2.4 Qloo Taste Intelligence API
- **Source Files**:
  - [app/lib/core/services/qloo_provider.dart](file:///d:/Nandhu/spotify/app/lib/core/services/qloo_provider.dart)
- **Base Endpoint**: `https://api.qloo.com/v2/insights`
- **Configuration**:
  - Key entered by user in **Settings Page**.
  - Stored in `SharedPreferences` under key `qloo_api_key`.
- **Headers**:
  ```http
  X-Api-Key: <QLOO_API_KEY>
  Accept: application/json
  ```
- **Fallback**: If key is empty or API returns non-200, returns empty candidate list; application continues with local acoustic provider.

---

### 2.5 Spotify Album Artwork CDN
- **Source Files**:
  - [app/lib/core/services/cover_service.dart](file:///d:/Nandhu/spotify/app/lib/core/services/cover_service.dart)
- **Endpoints**: `https://i.scdn.co/image/...` (from `songs.csv` and Spotify CSV exports).
- **Caching**: Stored locally in `<appSupport>/spotless/covers/<songId>.jpg`.
- **Embedding**: Cached image bytes are read and embedded directly into the local audio file using Mutagen (`APIC` frame for MP3 / `covr` for MP4). Once embedded, `Songs.artEmbedded` is set to `true`.
- **Fallback**: If Spotify CDN URL fails, falls back to YouTube thumbnail (`https://i.ytimg.com/vi/<id>/mqdefault.jpg`).

---

### 2.6 ExoPlayer Localhost Proxy Bridge
- **Source Files**:
  - `just_audio` package internal server (`127.0.0.1:<port>`)
  - [app/android/app/src/main/res/xml/network_security_config.xml](file:///d:/Nandhu/spotify/app/android/app/src/main/res/xml/network_security_config.xml)
- **Configuration**:
  ```xml
  <network-security-config>
      <domain-config cleartextTrafficPermitted="true">
          <domain includeSubdomains="false">127.0.0.1</domain>
          <domain includeSubdomains="false">localhost</domain>
      </domain-config>
  </network-security-config>
  ```
- **Crucial Rule**: Local audio files must **never** be routed through this proxy. `AudioEngine._sourceFor()` passes `headers: null` for all local `file:` paths to ensure direct ExoPlayer disk reading.
