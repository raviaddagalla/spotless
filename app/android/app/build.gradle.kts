import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.chaquo.python")
}

// Release signing is read from android/key.properties when present. That file
// and the keystore are gitignored; without them local release builds fall back
// to debug signing so they remain installable, and MUST NOT be published.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "com.nandhu.spotless"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nandhu.spotless"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            // Flutter 3.35+ pre-sets all three ABIs; clear first so Chaquopy
            // (Python 3.12, 64-bit only) doesn't try to build armeabi-v7a.
            abiFilters.clear()
            abiFilters.addAll(listOf("arm64-v8a", "x86_64"))
        }
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                // Local-only fallback. The build report records this; never
                // distribute this APK as a production release.
                signingConfigs.getByName("debug")
            }
        }
    }
}

chaquopy {
    defaultConfig {
        version = "3.12"
        // Override with CHAQUOPY_PYTHON when building on another machine/CI.
        // The old hardcoded Windows user path made the project unbuildable
        // anywhere else.
        buildPython(System.getenv("CHAQUOPY_PYTHON") ?: "python")
        pip {
            // Pinned so builds are reproducible. If YouTube breaks again,
            // bump this version and rebuild (this is the update path).
            install("yt-dlp==2026.7.4")
            install("mutagen==1.48.1")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
