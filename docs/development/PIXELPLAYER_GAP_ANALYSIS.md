# Spotless — PixelPlayer Feature & UX Gap Analysis

Reference: https://github.com/PixelPlayerHQ/PixelPlayer (commit `63cb59b`,
shallow clone inspected in `_pixelplayer_ref/`, gitignored).

## 1. Reference inspection

PixelPlayer is a 100% Kotlin/Jetpack Compose Android player (Media3 ExoPlayer,
Room, Hilt, Glance widgets). Documented surfaces and screens inspected:

- Home, Library, Search, Album/Artist/Genre detail, Playlist detail/create,
  Recently Played, Daily Mix, Stats, Equalizer, Settings (categories,
  experimental, palette style, nav-bar radius), Folder Explorer, Setup, About.
- Playback service, queue, crossfade/transition editor, sleep timer, tag editor,
  backup/restore, lyrics (LRCLIB), artist artwork (Deezer), Android Auto (listed
  as "soon"), Chromecast, Glance widget, AI playlists.

Spotless is Flutter + just_audio + audio_service + drift, with YouTube
streaming/download through an embedded Python/yt-dlp runtime. It is a
different product: personal library + YouTube acquisition + taste/session
recommendations, not a local-only Media3 player.

## 2. Licensing

PixelPlayer's `LICENSE` is **proprietary**: personal, non-commercial study/use
is allowed, but redistribution of the software or derivative works is
prohibited without written permission. Therefore:

- **No PixelPlayer source code, resources or Compose implementations were
  copied.**
- Only product-level behaviour and publicly documented feature ideas were used.
- All Spotless changes are independent Flutter/Dart/Kotlin/Python
  implementations.
- UI patterns already present in Spotless (immersive lyrics, dynamic colour,
  queue sheet) predate this pass and are generic music-player patterns, not
  copied assets.

## 3. Feature matrix

| Feature | PixelPlayer behaviour | Spotless current behaviour | Gap | Value | Complexity | Recommendation |
|---|---|---|---|---|---|---|
| Audio engine | Media3 ExoPlayer + FFmpeg | just_audio + audio_service, one engine | None functionally; different stack | — | — | Keep Spotless engine (no second engine) |
| Background playback / media session | Full Media3 session, notification, lock screen | audio_service foreground service, notification, media buttons | Parity | High | — | Preserve; fixed stop/crossfade/session-index bugs |
| Gapless playback | Advertised seamless transitions | Loads next track on completion; small gap | Real gap | Medium | High (ConcatenatingAudioSource conflicts with custom crossfade) | Optional; defer |
| Crossfade | Configurable transitions | 4 s on/off toggle | Duration not configurable | Low–Medium | Low | Optional; not changed |
| Queue management | Drag-and-drop reorder | Queue sheet + `ReorderableListView`, move up/down | Parity | — | — | Preserve; fixed shuffle/insert/remove corruption |
| Shuffle & repeat | All modes | Normal + Smart Shuffle, repeat off/all/one | Parity/stronger | — | — | Preserve |
| Sleep timer | Yes | Yes (settings + player) | Parity | — | — | Preserve |
| Multi-format local library | MP3/FLAC/AAC/OGG/WAV | Previously MP3-only, non-recursive | Large | High | Low | **Implemented**: recursive scan + 8 extensions |
| Folder filtering / explorer | Folder picker, exclusions, explorer | Single library root, recursive scan | Partial | Medium | Medium | Adapt folder exclusions later; root picker already exists |
| Metadata preservation on rescan | Room upsert semantics | `insertOrReplace` wiped play counts/ratings/likes | Critical | High | Medium | **Implemented**: in-place metadata merge |
| Album artist grouping | Proper album-artist grouping | Title-only grouping merged artists (fixed to album+artist) | Medium | Medium | Low | **Implemented** |
| Full-text search | Library full-text | Library search + YouTube search tab | Parity | — | — | Preserve |
| Statistics | Listening stats screen | Events/plays stored, no stats screen | Gap | Medium | Medium | Optional; data already collected |
| Backup / restore | JSON/zip backup of library and settings | None | Gap | High (data safety) | High | Optional; recommended next |
| Tag editor | TagLib editing | `mutagen` set_tags exists internally, no UI | Gap | Low–Medium | Medium | Optional |
| Equalizer | Built-in equalizer | None | Gap | Medium | High (native audio effect integration) | Reject for now; not core to YouTube streaming |
| Home-screen widget | Glance widget | None | Gap | Low | High (native home_widget plugin + Android code) | Reject for now |
| Android Auto | "Soon" | None | Gap | Low | High | Reject |
| Chromecast | Yes | None | Gap | Low | Very high | Reject |
| AI playlists | Multiple LLM providers | None | Gap | Low | Medium + paid keys | Reject (violates no-unnecessary-paid-dependency rule) |
| Daily Mix | Personalized mix from listening habits | Discovery screen with session + long-term taste | Partial | High | Medium | **Adapted**: session-scoped seeds + long-term seeds, no new screen |
| Lyrics: synced LRC, auto-scroll, click-to-seek | Yes | Yes, immersive page, LRCLIB, auto-scroll, tap-to-seek | Parity | — | — | Preserve |
| Lyrics matching accuracy | Not verified | Fuzzy match had no duration guard; local `.lrc` could be overwritten | High | High | Medium | **Implemented**: duration-aware scoring, >8 s rejection, local-first |
| Lyrics editing | Yes | No | Gap | Low | Medium | Reject; fetched lyrics are read-only by design |
| Artist artwork | Deezer artist images + cache | YouTube/album art only | Gap | Low–Medium | Medium | Optional; would add a third-party API dependency |
| Dynamic colour / Material You | Wallpaper + album-art palettes, palette styles | Album-art dominant colour + Material 3 dynamic scheme | Parity | — | — | Preserve |
| UI customisation (corner radius, nav bar) | Many knobs | Fixed design tokens | Gap | Low | Low | Optional; avoid settings bloat |
| Smart artist parsing (delimiters) | Configurable multi-artist delimiters | Single artist field | Gap | Low | Medium | Optional |
| Downloads queue | Not a focus (local player) | Added visible serialized queue with progress/cancel/retry | Spotless-specific | High | — | **Implemented** (product need, not copied) |
| Canonical YouTube matching | N/A | First-result selection; wrong live/cover risk | Critical for Spotless | High | Medium | **Implemented**: candidate scoring + canonical search |
| Session/taste model | Not documented | Continuity sessions, ratings, long-term taste | Spotless-specific | High | — | Preserve and hardened (heartbeat, activity events) |

## 4. Selected for this pass

Implemented because they improve core listening reliability or fix data loss:

1. Non-destructive library rescan and broader format support (PixelPlayer's
   library robustness, independently implemented).
2. Album+artist grouping with cover art.
3. Duration-aware lyrics matching with local-first preservation.
4. Immersive lyrics interaction was already present; fetch/refresh correctness
   was fixed.
5. Session-based recommendation seeds separated from long-term taste.
6. Visible download queue with cancel/retry (Spotless need; PixelPlayer has no
   equivalent acquisition flow).

## 5. Deliberately not implemented

| Item | Reason |
|---|---|
| Equalizer | Requires native audio-effect integration incompatible with the current just_audio/Chaquopy design; large risk for marginal benefit on streamed audio |
| Gapless playback | Conflicts with the existing dual-player crossfade; high regression risk for a small perceived gain |
| Widget / Android Auto / Chromecast | Large native surface, out of scope for a personal sideloaded app |
| AI playlists | Adds paid API dependencies and contradicts the offline/taste-based design |
| Backup/restore | Valuable but needs a versioned format and migration tests; deferred, not silently dropped |
| Tag editor UI | `setTags` plumbing exists but editing local files is not a current product need |
| PixelPlayer code/assets | Proprietary license; copying prohibited |

## 6. UX patterns adopted (independent implementation)

- Immersive full-screen lyrics with gradient and active-line typography
  (`ui/lyrics_page.dart`, `ui/widgets/synced_lyrics_view.dart`).
- Queue as a bottom sheet with drag handles (`QueueSheet`).
- Dense discovery cards with inline 1–10 rating and one-tap streaming.
- Album grid with representative artwork and artist subtitle.
- Settings grouped into library, playback, discovery, data and about sections.

No Kotlin source, Compose screen, drawable or string resource from PixelPlayer
was reused.
