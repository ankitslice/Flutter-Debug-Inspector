# Embedding the Flutter Debug Inspector in a native Android app (AAR)

The inspector **UI is Flutter**. To use it from a **plain Android app**, embed this repo’s Flutter **module** via **`flutter build aar`**. That produces a local Maven repository of AARs, including:

| Artifact | Role |
|----------|------|
| `com.example.inspector_host_module:flutter_*:1.0` | Your Dart UI + app code (`inspector_host_module`) |
| `com.example.flutter_debug_inspector:flutter_debug_inspector_*:1.0` | Plugin native side (pulled in transitively) |
| `io.flutter:*` (embedding + engines) | From `download.flutter.io` |

`*` is `debug`, `profile`, or `release` matching your build type.

## 1. Build the Maven repo

From the repo root:

```bash
cd inspector_host_module
flutter pub get
flutter build aar
```

Artifacts are written to:

`inspector_host_module/build/host/outputs/repo/`

Rebuild and **re-copy or re-point** this folder whenever you change Dart/plugin code or upgrade Flutter (engine versions in POMs will change).

## 2. Gradle: repositories

**Groovy** (`settings.gradle` or top-level `build.gradle` repositories block):

```groovy
def localFlutterRepo = "/absolute/path/to/FlutterDebugInspector/inspector_host_module/build/host/outputs/repo"
def storageUrl = System.env.FLUTTER_STORAGE_BASE_URL ?: "https://storage.googleapis.com"

repositories {
    maven { url localFlutterRepo }
    maven { url "$storageUrl/download.flutter.io" }
    google()
    mavenCentral()
}
```

**Kotlin DSL** (`settings.gradle.kts`):

```kotlin
val localFlutterRepo = file("/absolute/path/to/FlutterDebugInspector/inspector_host_module/build/host/outputs/repo")
val storageUrl = System.getenv("FLUTTER_STORAGE_BASE_URL") ?: "https://storage.googleapis.com"

dependencyResolutionManagement {
    repositories {
        maven { url = uri(localFlutterRepo) }
        maven { url = uri("$storageUrl/download.flutter.io") }
        google()
        mavenCentral()
    }
}
```

Use a path that works on every machine (CI: copy `repo` into the project or publish to an internal Maven server).

## 3. Gradle: dependencies

In **`app/build.gradle`** (or `.kts`):

**Groovy**

```groovy
dependencies {
    debugImplementation 'com.example.inspector_host_module:flutter_debug:1.0'
    profileImplementation 'com.example.inspector_host_module:flutter_profile:1.0'
    releaseImplementation 'com.example.inspector_host_module:flutter_release:1.0'
}
```

**Kotlin DSL**

```kotlin
dependencies {
    debugImplementation("com.example.inspector_host_module:flutter_debug:1.0")
    profileImplementation("com.example.inspector_host_module:flutter_profile:1.0")
    releaseImplementation("com.example.inspector_host_module:flutter_release:1.0")
}
```

You do **not** need a separate line for `flutter_debug_inspector`; it is a **transitive** dependency of `flutter_release` / `flutter_debug` / `flutter_profile`.

## 4. `profile` build type

Flutter’s AAR integration expects a **`profile`** variant. If you do not have it:

**Groovy**

```groovy
android {
    buildTypes {
        profile {
            initWith debug
        }
    }
}
```

**Kotlin DSL**

```kotlin
android {
    buildTypes {
        create("profile") {
            initWith(getByName("debug"))
        }
    }
}
```

## 5. Show the inspector UI

The module exposes:

- `/` — small shell with a button  
- `/inspector` — full **Debug Inspector** screen  

Register a `FlutterActivity` in your app (see [Add a Flutter screen](https://docs.flutter.dev/add-to-app/android/add-flutter-screen)), then open that activity.

**Stable approach:** subclass `FlutterActivity` and pin the route:

```kotlin
import io.flutter.embedding.android.FlutterActivity

class InspectorFlutterActivity : FlutterActivity() {
    override fun getInitialRoute(): String = "/inspector"
}
```

```xml
<activity
    android:name=".InspectorFlutterActivity"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize"
    android:exported="false" />
```

Start it with a normal `Intent` when you want the inspector.

Alternatively, if your embedding exposes an intent builder, set **`initialRoute("/inspector")`** and Dart entrypoint **`main`** for `inspector_host_module`.

## 6. Hybrid apps (multiple engines)

1. Before running Flutter UI, set on the JVM side:

   `FlutterDebugInspectorPlugin.registry.isHybridApp = true`

2. Register engines / channels with `FlutterDebugInspectorPlugin.registry` as in the main README / integration guide.

3. Pass the same `engineName` into Dart observers (`FrameTimingCollector`, `DebugNavigatorObserver`, etc.) inside the Flutter module if you customize entrypoints per engine.

## 7. Version and coordinates

- **Module** `groupId` / `artifactId` come from `inspector_host_module/pubspec.yaml` → `flutter.module.androidPackage` (`com.example.inspector_host_module`) and Flutter’s `flutter_*` artifact naming.
- **Plugin** coordinates are `com.example.flutter_debug_inspector:flutter_debug_inspector_<variant>:1.0` (version **1.0** matches the current AAR output).

To ship to a team Maven repo, copy `build/host/outputs/repo/**` into your artifact repository or use `mvn deploy`/Gradle publish with the same layout.

## 8. Publish to GitHub Packages (remote Maven)

This repo includes a workflow that uploads **only** the two `com.example.*` libraries (all `debug` / `profile` / `release` AAR variants). **`io.flutter` artifacts are not uploaded** — every Android app must still use Google’s Flutter Maven repo.

### Publish (maintainer)

1. Push this repository to GitHub.
2. Open **Actions** → **Publish AAR to GitHub Packages** → **Run workflow** (or create a **Release** to run it automatically).
3. After it succeeds, packages appear under the repo’s **Packages** (Maven).

Or locally (after `flutter build aar`), with a PAT that has **`write:packages`**:

```bash
export GITHUB_REPOSITORY="your-org/FlutterDebugInspector"
export GITHUB_ACTOR="your-github-username"
export GITHUB_TOKEN="ghp_..."   # or GPR_USER / GPR_TOKEN
./tool/publish_github_packages.sh
```

Re-publishing the same version (`1.0`) may fail until you delete that package version in GitHub or bump versions in the Flutter/POM outputs.

### Consume from GitHub Packages (your Android app)

Replace **`OWNER/REPO`** with the GitHub repo where you published (same repo as this project).

**Groovy** — `settings.gradle` / `dependencyResolutionManagement`:

```groovy
def storageUrl = System.env.FLUTTER_STORAGE_BASE_URL ?: "https://storage.googleapis.com"

repositories {
    maven {
        url = uri("https://maven.pkg.github.com/OWNER/REPO")
        credentials {
            username = findProperty("gpr.user") ?: System.getenv("GPR_USER")
            password = findProperty("gpr.key") ?: System.getenv("GPR_TOKEN")
        }
    }
    maven { url "$storageUrl/download.flutter.io" }
    google()
    mavenCentral()
}
```

Create a [Personal Access Token](https://github.com/settings/tokens) with **`read:packages`**. Use it as `GPR_TOKEN` (and your GitHub username as `GPR_USER`). CI can inject these as secrets.

**Dependencies** stay the same as in [section 3](#3-gradle-dependencies):

```groovy
debugImplementation 'com.example.inspector_host_module:flutter_debug:1.0'
profileImplementation 'com.example.inspector_host_module:flutter_profile:1.0'
releaseImplementation 'com.example.inspector_host_module:flutter_release:1.0'
```

Gradle resolves `flutter_debug_inspector_*` transitively from the module POM.
