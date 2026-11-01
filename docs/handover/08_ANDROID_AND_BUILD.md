# 08 — Android Platform and Build Configuration

> **Document Version**: 1.0.0  
> **Date**: November 1, 2026  
> **Target Package**: `com.nandhu.spotless`  

---

## 1. Android Platform Specifications

```
Application ID / Package Name : com.nandhu.spotless
Minimum SDK                   : 24 (Android 7.0 Nougat)
Target SDK                    : 34 (Android 14 UpsideDownCake)
Compile SDK                   : 34 (or flutter.compileSdkVersion)
Java Version                  : Java 17 (JavaVersion.VERSION_17)
Kotlin Version                : 2.1.0 (org.jetbrains.kotlin.android)
Android Gradle Plugin (AGP)   : 8.13.0
Gradle Distribution           : 8.13 (gradle-8.13-all.zip)
Chaquopy Plugin               : 17.0.0 (com.chaquo.python)
Embedded Python Engine        : Python 3.12 (64-bit)
Supported ABIs                : arm64-v8a, x86_64 (armeabi-v7a excluded)
```

---

## 2. Manifest, Services, and Permissions

### 2.1 Permissions (`AndroidManifest.xml`)
- `INTERNET`: Network access for YouTube extraction, streaming, lyrics, covers.
- `ACCESS_NETWORK_STATE`: Network availability detection.
- `WAKE_LOCK`: Keeps CPU awake during audio decoding and downloads.
- `FOREGROUND_SERVICE`: Background media playback service.
- `FOREGROUND_SERVICE_MEDIA_PLAYBACK`: Required on Android 14+ (API 34) for continuous media playback.
- `POST_NOTIFICATIONS`: Android 13+ (API 33) notification permission for media drawer.
- `MANAGE_EXTERNAL_STORAGE`: Required on Android 11+ (API 30+) to scan the user's music folder (`/storage/emulated/0/Download/songs_download`). Must be granted manually via Android Settings -> Special App Access -> All Files Access.
- `READ_EXTERNAL_STORAGE` (maxSdkVersion 32) & `READ_MEDIA_AUDIO`: Audio file access fallbacks.

### 2.2 Application & Service Declarations
- **Application Class**:
  ```xml
  android:name="com.chaquo.python.android.PyApplication"
  ```
  *Why*: Initializes the embedded Chaquopy Python runtime before Flutter launches.
- **Network Security**:
  ```xml
  android:networkSecurityConfig="@xml/network_security_config"
  ```
  Permits cleartext HTTP to `127.0.0.1` and `localhost` so `just_audio`'s loopback streaming proxy functions.
- **Audio Service**:
  ```xml
  <service
      android:name="com.ryanheise.audioservice.AudioService"
      android:foregroundServiceType="mediaPlayback"
      android:exported="true"
      tools:ignore="Instantiatable">
      <intent-filter>
          <action android:name="android.media.browse.MediaBrowserService" />
      </intent-filter>
  </service>
  ```
- **Media Button Receiver**:
  ```xml
  <receiver
      android:name="com.ryanheise.audioservice.MediaButtonReceiver"
      android:exported="true"
      tools:ignore="Instantiatable">
      <intent-filter>
          <action android:name="android.intent.action.MEDIA_BUTTON" />
      </intent-filter>
  </receiver>
  ```

---

## 3. Chaquopy Configuration (`app/android/app/build.gradle.kts`)

```kotlin
android {
    defaultConfig {
        ndk {
            // Flutter 3.35+ pre-sets all three ABIs; clear first so Chaquopy
            // (Python 3.12, 64-bit only) doesn't try to build armeabi-v7a.
            abiFilters.clear()
            abiFilters.addAll(listOf("arm64-v8a", "x86_64"))
        }
    }
    buildTypes {
        release {
            // Signing with debug keys so release APK installs directly without custom keystore
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

chaquopy {
    defaultConfig {
        version = "3.12"
        buildPython("C:/Users/aravi/AppData/Local/Programs/Python/Python312/python.exe")
        pip {
            install("yt-dlp==2026.7.4")
            install("mutagen")
        }
    }
}
```

> [!IMPORTANT]
> **Host Python Dependency**: Chaquopy requires a host Python executable during Gradle build time to compile wheels. On this machine, it is located at:  
> `C:/Users/aravi/AppData/Local/Programs/Python/Python312/python.exe`.  
> If migrating to a new build machine, update this path or ensure Python 3.12 is on system `PATH`.

---

## 4. Build Commands & APK Generation

### 4.1 Debug APK
```powershell
cd d:\Nandhu\spotify\app
& "C:\Users\aravi\flutter\bin\flutter.bat" build apk --debug
```
- **Output**: `app/build/app/outputs/flutter-apk/app-debug.apk` (~187MB, includes debug symbols and both ABIs).

### 4.2 Release APK (Universal arm64 + x86_64)
```powershell
cd d:\Nandhu\spotify\app
& "C:\Users\aravi\flutter\bin\flutter.bat" build apk --release
```
- **Output**: `app/build/app/outputs/flutter-apk/app-release.apk` (~83.6MB).
- Signed automatically with the debug keystore for easy sideloading.

### 4.3 Compact ARM64 Release APK (Recommended for Phone Deployment)
```powershell
cd d:\Nandhu\spotify\app
& "C:\Users\aravi\flutter\bin\flutter.bat" build apk --release --target-platform android-arm64
```
- **Output**: Produces a ~59MB APK containing only `arm64-v8a` native code.
- Works on 99% of modern Android physical smartphones.

> [!WARNING]
> Do NOT use `flutter build apk --split-per-abi`. It conflicts with Gradle's `ndk.abiFilters` block and causes build failure. Use `--target-platform android-arm64` instead.

---

## 5. Physical Device Installation & Debug Runbook

### 5.1 Verified Device Details
- **Hardware**: Realme Narzo 70 Pro 5G (Model: RMX3868)
- **Serial**: `AENVTKIFUSCY5TT4`
- **OS**: Android 14 (Realme UI 5.0)

### 5.2 Device Connection Check
```powershell
adb devices
```
If the device shows `unauthorized` or drops off, restart the adb server:
```powershell
adb kill-server; adb start-server
```

### 5.3 Installation Workaround (Bypassing `INSTALL_FAILED_VERIFICATION_FAILURE`)
On some Realme / ColorOS / MIUI devices, direct `adb install -r -t` is blocked by package verification. Use the two-step `pm install` method:
```powershell
adb push app\build\app\outputs\flutter-apk\app-release.apk /data/local/tmp/app.apk
adb shell pm install -r -t /data/local/tmp/app.apk
```

### 5.4 Launching the Application
```powershell
adb shell monkey -p com.nandhu.spotless -c android.intent.category.LAUNCHER 1
```

### 5.5 Extracting SQLite Database for Verification
Because Windows PowerShell can corrupt binary redirects, use `cmd /c` to pull the database:
```powershell
cmd /c "adb exec-out run-as com.nandhu.spotless cat app_flutter/spotless.sqlite > out.sqlite"
```
*(Note: Requires debug build or debuggable APK).*

### 5.6 Reading Python & Audio Logs
```powershell
adb logcat -s ytdlp -s just_audio -s Flutter
```
Durable on-device log file: `/data/user/0/com.nandhu.spotless/files/ytdlp_debug.log`.
