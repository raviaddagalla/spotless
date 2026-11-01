# 09 — Dependency Inventory and Compatibility Assessment

> **Document Version**: 1.0.0  
> **Date**: November 1, 2026  

---

## 1. Dart / Flutter Dependencies (`app/pubspec.yaml`)

| Package | Pinned / Declared Version | Purpose | Usage Location | Criticality | Replaceability | Known Compatibility Issues & Notes |
|---------|---------------------------|---------|----------------|-------------|----------------|-------------------------------------|
| `just_audio` | `^0.10.6` | Core audio playback engine (ExoPlayer wrapper) | `audio_engine.dart` | **CRITICAL** | Very Low | Routes requests with non-null headers through localhost proxy. Local files MUST use `headers: null`. |
| `audio_service` | `^0.18.19` | Background playback, notification drawer & lock screen media controls | `main.dart`, `audio_engine.dart` | **CRITICAL** | Very Low | Coupled with Android manifest declarations (`AudioServiceActivity`, `MediaButtonReceiver`). |
| `drift` | `^2.34.3` | Type-safe SQLite ORM | `core/db/` | **CRITICAL** | Very Low | Generates code via `drift_dev`. `JoinedSelectStatement.where` takes `Expression<bool>` directly (not callback). |
| `drift_flutter` | `^0.3.1` | Flutter SQLite connection provider | `app_database.dart` | **CRITICAL** | Medium | Simplifies path resolution on Android. |
| `provider` | `^6.1.5+1` | Dependency injection & state management | `main.dart`, `ui/` | **HIGH** | Medium (could use Riverpod/Bloc) | Fundamental to current UI rebuild flow (`context.watch`, `context.read`). |
| `palette_generator` | `^0.3.3+4` | Dynamic color extraction from album art | `dynamic_theme_provider.dart` | **MEDIUM** | High | Extracts dominant and vibrant colors to drive dynamic M3 theming. |
| `google_fonts` | `^6.2.1` | Custom typography (Inter/Outfit) | `spotless_typography.dart` | **MEDIUM** | High | Downloads fonts on demand; falls back to system font if offline. |
| `flutter_slidable` | `^4.0.3` | Swipe-to-action list tile interactions | `slidable_song_tile.dart` | **MEDIUM** | Medium | Used in Library, Liked Songs, and Playlists. |
| `cached_network_image` | `^3.4.1` | Asynchronous image loading with disk cache | `album_art.dart`, `discovery_page.dart` | **MEDIUM** | High | Caches remote cover art and thumbnails. |
| `file_picker` | `^11.0.3` | File selection for Spotify CSV import & library scanning | `settings_page.dart` | **HIGH** | Medium | Uses static `FilePicker.platform.pickFiles()`. |
| `share_plus` | `^11.0.1` | Android share sheet for playlist `.m3u` export | `playlists_page.dart` | **LOW** | High | Note: `Share.shareXFiles` is deprecated in v11; uses `SharePlus.instance.share(ShareParams(...))`. |
| `shared_preferences` | `^2.5.5` | Key-value store for app settings, API keys, and search history | `music_repository.dart` | **HIGH** | Low | Stores `library_root`, `offline_only`, `crossfade`, `search_history`, API keys. |
| `path_provider` | `^2.1.6` | Resolves app support and cache directory paths | `music_repository.dart` | **HIGH** | Low | Required to locate `files/spotless/` directory. |
| `path` | `^1.9.1` | Filesystem path joining and sanitization | Throughout `core/services/` | **HIGH** | Low | Standard Dart path manipulation utility. |
| `http` | `^1.6.0` | HTTP client for external APIs | `lastfm_provider.dart`, `qloo_provider.dart`, `cover_service.dart` | **HIGH** | Medium | Standard HTTP networking. |
| `permission_handler` | `^13.0.0` | Android runtime permission management | `library_scanner.dart` | **HIGH** | Medium | Governs `MANAGE_EXTERNAL_STORAGE` and notification requests. |

---

## 2. Critical Dependency Overrides

```yaml
dependency_overrides:
  # 14.0.0 hardcodes compileSdk 37 which is not in the SDK repo yet.
  permission_handler_android: 13.0.1
```

### Rationale
`permission_handler` version 14.0.0 released with a transitive dependency on `permission_handler_android: 14.0.0`, which strictly requires `compileSdk = 37`. Because Android SDK 37 is not yet stable or standard in early 2026, compiling against it causes Gradle build failures. Overriding to `13.0.1` keeps the build pinned to stable Android SDK 34/35 without loss of permission functionality.

---

## 3. Python Runtime Dependencies (`Chaquopy`)

Configured in `app/android/app/build.gradle.kts`:

| Package | Version | Purpose | Criticality | Upgrade Notes |
|---------|---------|---------|-------------|---------------|
| `yt-dlp` | `2026.7.4` | Audio stream extraction and YouTube downloading | **CRITICAL** | If YouTube changes bot detection or player clients, bump this version in `build.gradle.kts` and rebuild. |
| `mutagen` | Latest (`install("mutagen")`) | ID3v2.3/v2.4 and MP4 audio tag & cover art manipulation | **CRITICAL** | Very stable. Modifies `APIC` and `covr` frames natively. |
| `urllib` | Python Stdlib | HTTP requests to `lrclib.net` for synced lyrics | **HIGH** | No pip dependency required; zero-overhead stdlib client. |

---

## 4. Native Android Dependencies (`Gradle`)

Configured in `app/android/build.gradle.kts` and `app/android/app/build.gradle.kts`:

- **Gradle Plugin**: `dev.flutter.flutter-gradle-plugin`
- **Android Application Plugin**: `com.android.application:8.13.0`
- **Kotlin Android Plugin**: `org.jetbrains.kotlin.android:2.1.0`
- **Chaquopy Python Plugin**: `com.chaquo.python:17.0.0`
- **ExoPlayer (Media3)**: Transitive dependency imported automatically by `just_audio`.

---

## 5. Potential Compatibility Risks & Technical Debt

1. **`build_runner` and Drift Code Generation**: If `core/db/tables.dart` or `core/db/app_database.dart` are altered, `app_database.g.dart` will become out of sync. To regenerate:
   ```powershell
   & "C:\Users\aravi\flutter\bin\flutter.bat" pub run build_runner build --delete-conflicting-outputs
   ```
2. **Flutter 3.44 Deprecations Handled**:
   - `ReorderableListView.onReorder` is deprecated in Flutter 3.44; `playlist_songs_page.dart` and `now_playing_page.dart` use `onReorderItem` (where indices are pre-adjusted).
   - `Share.shareXFiles` is deprecated in `share_plus: ^11.0.0`; `music_repository.dart` uses `SharePlus.instance.share(ShareParams(...))`.
3. **No Unused or Duplicate Dependencies**: The dependency tree is lean and purposeful. There are no bloated third-party animation libraries or unnecessary utilities.
