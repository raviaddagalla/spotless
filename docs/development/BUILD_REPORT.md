# Spotless — Android Build Report

Build date: 2026-11-01. Machine: Windows 10.0.26300.9818, Flutter 3.44.8,
Dart 3.12.2, JDK 17.0.20.1, Gradle 8.14.3, compileSdk 36, targetSdk 36,
minSdk 24.

## Commands

```
cd app
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```

Raw logs were written to `docs/development/analyze.log`, `test.log`,
`build_debug.log`, `build_release.log` and the pre-change `baseline_*.log`
files. They are gitignored (`*.log`); the results are reproduced below.

## Results

| Build | Result | Time | Artifact |
|---|---|---|---|
| Debug APK (baseline) | Success | 1482.9 s (first Chaquopy provision) | 195 MB |
| Debug APK (final source) | Success | 127.1 s | `Spotless-0.1.0-debug.apk` |
| Release APK | Success | 242.6 s | `Spotless-0.1.0-release.apk` |

Release output from Flutter: `√ Built build\app\outputs\flutter-apk\app-release.apk (83.8MB)`.

## Artifacts

Directory: `artifacts/android/` (APKs are gitignored and are **not** committed).

| File | Bytes | SHA-256 |
|---|---:|---|
| `Spotless-0.1.0-debug.apk` | 204,225,063 | `e3594365ee5247a429f69e8a6c0a5f5b8818611ed3264f3ae939553a9dc07306` |
| `Spotless-0.1.0-release.apk` | 87,834,851 | `78bd020b8e803f5caa76b236066e949f97acd3e28d0ffbbb26db1e2db30e99f3` |

`artifacts/android/SHA256SUMS.txt` contains the same checksums in `sha256sum`
format.

## Release APK inspection

`aapt dump badging`:

```
package: name='com.nandhu.spotless' versionCode='1' versionName='0.1.0'
sdkVersion:'24' targetSdkVersion:'36'
```

Declared permissions (release):

- `INTERNET`, `ACCESS_NETWORK_STATE`, `WAKE_LOCK`
- `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`
- `POST_NOTIFICATIONS`
- `MANAGE_EXTERNAL_STORAGE`, `READ_EXTERNAL_STORAGE` (maxSdk 32),
  `READ_MEDIA_AUDIO`

Native libraries present for both supported ABIs:

- `arm64-v8a`: `libapp.so`, `libflutter.so`, `libpython3.12.so`,
  `libchaquopy_java.so`, `libsqlite3*.so`, `libssl/libcrypto`
- `x86_64`: same set (emulator support)

Chaquopy assets are packaged (`assets/chaquopy/...`), including the app's
`ytdlp.py` module and the pinned `yt-dlp==2026.7.4` / `mutagen==1.48.1`
dependencies.

Release is **not** minified/obfuscated (`minifyEnabled` not set), so no R8
keep rules are required for Chaquopy, audio_service or Flutter. This is a
deliberate safety choice for a personal app; it costs size, not correctness.

## Signing

- Release signing is read from `app/android/key.properties` (gitignored).
- Keystore: `app/android/spotless-release.jks` (gitignored, PKCS12, RSA 2048,
  validity 10,000 days, alias `spotless`).
- `apksigner verify --print-certs` on the release APK reports:
  `CN=Spotless, OU=Mobile, O=Spotless, L=Hyderabad, ST=Telangana, C=IN`,
  certificate SHA-256
  `0fe4b5ceab93a5d2576d00c7be81975f9e76fd4c9b346454fea267e5ec8f0e38`.
- The debug APK is signed with the standard Android debug certificate; it must
  not be distributed.
- If `key.properties` is absent, Gradle falls back to debug signing so the
  project stays buildable, and prints a build-report warning. The fallback APK
  is **not** a production release.

**Important:** the keystore is local-only and was generated for this build. It
is required to publish updates that Android will accept as the same app. Back
it up; it is not in Git and cannot be recovered from this repository.

## Installation / launch verification

**BLOCKED.** `adb devices` reports no device and `flutter emulators` reports no
AVD images installed. The APKs were therefore validated statically
(package id, version, manifest, ABI libs, Chaquopy assets, signature) but not
installed or launched. Do not treat static checks as runtime verification.

## Reproducibility

- Chaquopy `buildPython` uses `CHAQUOPY_PYTHON` when set, otherwise `python`
  from `PATH`. The previous hardcoded `C:/Users/aravi/...` path was removed.
- Python wheels are pinned in `app/android/app/build.gradle.kts`.
- `app/android/local.properties` is machine-specific and gitignored.
- `permission_handler_android` is pinned to 13.0.1 by `dependency_overrides`
  because 14.0.0 requires an unavailable compileSdk.

## Release configuration checks

| Check | Result |
|---|---|
| Application id | `com.nandhu.spotless` (unchanged) |
| Version | `0.1.0` (versionCode 1) |
| Debug signing in release | No — real release certificate |
| Secrets in APK | No API keys; Last.fm key is user-entered at runtime |
| Cleartext traffic | Disabled by `network_security_config.xml` |
| Foreground media service | Declared with `mediaPlayback` type + Android 14 permission |
| Python runtime | Packaged for arm64-v8a and x86_64 |
| Interpreter availability | CPython 3.12.10 present at build time |
