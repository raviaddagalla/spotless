# Spotless — Baseline Audit

Captured before any source modification in this engineering pass. Raw command
output was captured locally in the gitignored files listed below; the
essential output is reproduced in this document so the record survives a
clone:

| Log | Command |
|---|---|
| `baseline_analyze.log` | `flutter analyze` |
| `baseline_test.log` | `flutter test` |
| `baseline_build_debug.log` | `flutter build apk --debug` |
| `analyze.log` / `test.log` / `build_debug.log` | same commands after the fixes |

## Environment

| Item | Value |
|---|---|
| OS | Windows 10.0.26300.9818 (x64) |
| Flutter | 3.44.8 stable, framework revision 058e0af2c2 |
| Dart | 3.12.2 |
| Java | OpenJDK 17.0.20.1 LTS (Microsoft) |
| Gradle | 8.14.3 (wrapper) |
| Android SDK | configured through `app/android/local.properties`; compileSdk/targetSdk from Flutter Gradle plugin |
| Android build tools | from installed SDK; NDK version from Flutter |
| Python (Chaquopy build) | CPython 3.12.10 at `C:/Users/aravi/AppData/Local/Programs/Python/Python312/python.exe` |
| Connected Android devices | **none** (`adb devices` empty, no AVD images) |
| Free disk on `D:` | 76 GiB |

The project pins `yt-dlp==2026.7.4` and `mutagen==1.48.1` through Chaquopy.
No toolchain upgrade was performed.

## Git state at start

```
branch: main
HEAD:   2511433 docs(handover): generate comprehensive engineering handover dossier (17 documents)
remote: https://github.com/raviaddagalla/spotless.git
```

The working tree contained the previous agent's uncommitted work (handover
dossier was committed; application fixes and new files were not). Those changes
were preserved, reviewed, extended and are the subject of this pass. No reset,
stash or branch switch was performed.

## Baseline results

### 1. Dependency install

`flutter pub get` resolved successfully from the existing lockfile. No
dependency versions were changed by this pass.

### 2. Static analysis

```
flutter analyze
Analyzing app...
No issues found! (ran in 53.3s)
```

### 3. Tests

```
flutter test
00:07 +20: All tests passed!
```

20 tests existed: discovery (4), session/rating/lyrics (14), shuffle (2).
There were no tests for the library scanner, download queue, lyrics fetch
races or queue mutation.

### 4. Debug APK

```
flutter build apk --debug
...
√ Built build\app\outputs\flutter-apk\app-debug.apk
exit 0
```

First build took 1482.9 s because Chaquopy downloaded and installed the Python
runtime and wheels for both ABIs. Subsequent builds reuse the cached runtime.

### 5. Release APK

Not attempted at baseline. Release signing was wired to the debug key
(`signingConfig = signingConfigs.getByName("debug")`), so a "release" build
would not have been distributable. This is addressed in this pass with a local
release keystore (never committed).

### 6. Device tests

Blocked: no physical Android device and no emulator/AVD is installed on this
machine. All on-device checks are reported as BLOCKED, not PASS.

## Pre-existing limitations recorded, not hidden

- `app/android/app/build.gradle.kts` hardcoded a Windows user's Python path,
  making the project unbuildable on any other machine.
- Release builds were debug-signed.
- No Android instrumentation/widget tests exist; all coverage is unit tests
  against drift databases and pure logic.
- `MANAGE_EXTERNAL_STORAGE` is requested for arbitrary folder scanning. This is
  acceptable for a sideloaded personal app but is a Play Store policy risk.
- The app depends on YouTube extraction through yt-dlp. Changes on YouTube's
  side can break streaming/downloads independently of this codebase; the
  pinned version is the supported update path.
