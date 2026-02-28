# Echoes: Technical Architecture & Developer Guide

Welcome to the **Echoes** codebase. This document is a comprehensive developer reference covering the app's architecture, technology stack, data models, services, UI layer, and known areas for future improvement. It is intended to onboard new contributors and serve as a single source of truth for architectural decisions.

---

## 1. App Overview & Core Philosophy

**Echoes** is a privacy-first, fully offline iOS application designed to help users record, transcribe, and preserve personal audio memories. The central philosophy is **on-device processing**: all audio capture, speech transcription, facial emotion detection, and theme classification happen entirely on the user's device. No audio file, transcript, or personal data ever leaves the device or touches a remote server.

The app is built to be emotionally resonant. It uses guided prompts to inspire storytelling, captures the speaker's smile moments in real time, and organizes memories into a rich thematic library that grows more meaningful over time.

### Key Features

| Feature | Description |
|---|---|
| Audio Recording | High-fidelity (AAC 128kbps) or Space Saver (AAC 64kbps) quality, with live decibel metering |
| On-Device Transcription | Full-length speech-to-text via a PCM buffer streaming technique that bypasses Apple's default ~15s URL-transcription limit |
| Emotion Tracking | Real-time smile detection via the front camera and Vision framework; detected smiles are logged as "joy pin" timestamps |
| Theme Analysis | CoreML-powered classification of the transcript into one of eight thematic categories |
| Guided Prompts (Kindle) | A curated, swipeable deck of story prompts organized by theme to guide recording sessions |
| Library | Filterable, searchable grid of all recorded Echoes with playback, favoriting, and speaker attribution |
| Orbit View | A statistics dashboard showing recording streaks, total hours, and thematic distribution |
| Speaker Profiles | Named profiles with custom avatar photos for attributing memories to specific people |
| Biometric Lock | Optional Face ID / Touch ID authentication via LocalAuthentication to protect the memory vault |

---

## 2. Technology Stack

The app is built exclusively on Apple's native framework ecosystem to maintain its offline-first guarantee.

| Layer | Framework / Technology | Purpose |
|---|---|---|
| UI | SwiftUI | All views, modifiers, animations, and custom components |
| Persistence | SwiftData | Declarative local database modeling; replaces CoreData |
| Audio | AVFoundation | `AVAudioRecorder`, `AVAudioPlayer`, `AVAudioPCMBuffer` for record/playback/streaming |
| Transcription | Speech Framework (`SFSpeechRecognizer`) | On-device speech-to-text; strictly no network fallback |
| Face Tracking | Vision Framework (`VNDetectFaceLandmarksRequest`) | Real-time facial landmark detection for smile scoring |
| ML / NLP | CoreML + NaturalLanguage (`NLModel`) | Custom trained `EchoThemeClassifier.mlmodel` for theme prediction |
| Reactivity | Observation (`@Observable`) | Native state propagation across services and view models |
| Authentication | LocalAuthentication (`LAContext`) | Biometric (Face ID / Touch ID) vault protection |
| File I/O | Foundation (`FileManager`) | Permanent audio/image persistence in the App Documents directory |

### Minimum Deployment Target

- **iOS 17.0+** (required for SwiftData and the `@Observable` macro)
- **Xcode 15.0+**

---

## 3. Project Structure

```
Echoes/
├── EchoesApp.swift          # App entry point, SwiftData container, sample data seeding
├── ContentView.swift        # Root content view (delegates immediately to MainTabView)
├── Models/
│   ├── Echo.swift           # Primary SwiftData entity for a recorded memory
│   ├── SpeakerProfile.swift # SwiftData entity for named speaker profiles
│   ├── Prompt.swift         # Value type for story prompts + static sample deck
│   ├── ThemeCategory.swift  # Enum of 8 themes with colors, SF Symbols icons
│   └── ML/
│       └── EchoThemeClassifier.mlmodel  # On-device CoreML text classifier
├── Services/
│   ├── AudioRecorderManager.swift       # AVAudioSession + AVAudioRecorder lifecycle
│   ├── AudioPlayerManager.swift         # AVAudioPlayer playback + seek control
│   ├── CameraStreamService.swift        # Camera session management & frame dispatch
│   ├── FaceTrackingService.swift        # Vision landmark analysis & joy pin logging
│   ├── TranscriptionService.swift       # PCM buffer streaming transcription
│   ├── ThemeAnalyzerService.swift       # CoreML model wrapper for theme prediction
│   ├── StorageManager.swift             # FileManager wrapper for permanent storage
│   ├── CaptureSessionManager.swift      # Orchestrator across all capture-phase services
│   ├── RecordingManager.swift           # High-level recording state machine
│   └── BiometricAuthService.swift       # LocalAuthentication wrapper
├── Views/
│   ├── MainTabView.swift                # Root tab controller + first-run sequence FSM
│   ├── SplashScreenView.swift           # Launch splash animation
│   ├── Onboarding/
│   │   └── OnboardingView.swift         # 3-slide onboarding (Welcome, Privacy, Action)
│   ├── Kindle/                          # Swipeable prompt deck view
│   ├── Capture/                         # Recording screen + live metering
│   ├── Library/                         # Echo grid + filter chips
│   ├── Playback/                        # Audio player + transcript + joy pins
│   ├── Orbit/                           # Stats dashboard + streak tracking
│   ├── Profile/                         # Speaker profile creation & management
│   ├── Settings/                        # App settings + biometric toggle + tutorial
│   └── Components/                      # Reusable UI components
└── Theme/                               # NeoRetro design system (colors, styles, modifiers)
```

---

## 4. Data Models

### 4.1 `Echo` (Primary Entity)

`Echo` is the central SwiftData `@Model` class. Each instance represents one complete recorded memory.

```swift
@Model final class Echo {
    var id: UUID
    var dateRecorded: Date
    var title: String
    var speakerName: String
    var promptText: String       // The prompt that guided this recording
    var duration: Double         // In seconds
    var transcript: String       // Full on-device transcription of the audio
    var themeTag: String         // Output of ThemeAnalyzerService (e.g., "Romance")
    var joyPins: [Double]        // Array of TimeIntervals where smiles were detected
    var audioFilename: String    // Filename only, not a full path
    var coverImageFilename: String?
    var isFavorite: Bool
}
```

**Key Design Decision:** Heavy binary assets (audio files, cover images) are **not** stored as binary blobs inside the SwiftData store. Instead, `Echo` stores lightweight filename strings that point to external files managed by `StorageManager` in the app's `DocumentDirectory`. This keeps the SwiftData SQLite database small and prevents memory pressure during large library queries.

### 4.2 `SpeakerProfile`

Represents a named person whose voice is captured in Echoes. Profiles are linked to Echoes by name (string match) rather than a foreign key relationship, keeping the schema simple.

```swift
@Model final class SpeakerProfile {
    @Attribute(.unique) var name: String
    var avatarFilename: String?   // Optional custom avatar photo
}
```

### 4.3 `Prompt`

A value-type struct (not a SwiftData model) representing a single story prompt card. The static `Prompt.samples` array is the curated library of 24 prompts across 8 themes, organized in 3 cycles of 8.

```swift
struct Prompt: Identifiable {
    let id: UUID
    let text: String        // Primary question text
    let subtitle: String    // Contextual hint beneath the main question
    let category: String    // ThemeCategory raw value
    let icon: String        // SF Symbol name
    var colorHex: String
    var isSaved: Bool
}
```

### 4.4 `ThemeCategory`

An enum of the eight supported memory themes. Each case carries its display name, a unique pastel color hex value, and an SF Symbol icon for consistent rendering across the Kindle, Library, and Orbit views.

| Case | Color | Icon |
|---|---|---|
| `.childhood` | Tangerine (`#FFB067`) | `figure.child` |
| `.romance` | Bubblegum (`#FF9CEE`) | `heart.fill` |
| `.family` | Sage (`#A4C3A2`) | `person.2.fill` |
| `.travel` | Turquoise (`#90E0EF`) | `airplane` |
| `.home` | Tangerine (`#FFB067`) | `house.fill` |
| `.lessons` | Lilac (`#dcd6f7`) | `book.fill` |
| `.wisdom` | Lavender (`#B8A7EA`) | `lightbulb.fill` |
| `.work` | Turquoise (`#90E0EF`) | `briefcase.fill` |

---

## 5. Services Layer

All heavy lifting is offloaded to single-responsibility service classes marked with `@Observable` for SwiftUI reactivity. Services communicate failures via console logs; a formal error propagation system is listed as future work.

### 5.1 `AudioRecorderManager`

Manages the entire `AVAudioSession` and `AVAudioRecorder` lifecycle.

- Configures the audio session for `.playAndRecord` with `.duckOthers` mixing
- Writes a temporary `.m4a` file to the `tmp` directory during recording
- Publishes real-time decibel levels to drive the waveform visualizer
- Exposes recording quality presets: **High Fidelity** (128kbps AAC) and **Space Saver** (64kbps AAC)

### 5.2 `TranscriptionService`

Handles on-device speech-to-text transcription of the finished `.m4a` file.

**The PCM Buffer Streaming Technique:** Apple's `SFSpeechRecognizer` imposes a strict ~15-second transcription limit when recognizing from a URL directly. To bypass this, `TranscriptionService` reads the full audio file into an `AVAudioPCMBuffer`, then feeds audio data chunk-by-chunk to an `SFSpeechAudioBufferRecognitionRequest`. This approach processes recordings of arbitrary length entirely on-device without any network access.

### 5.3 `FaceTrackingService`

Runs continuously during the recording phase to detect emotional moments.

- Receives `CMSampleBuffer` frames from `CameraStreamService`
- Runs `VNDetectFaceLandmarksRequest` on each frame
- Calculates a "Smile Index" by measuring the geometric ratio of mouth corner distance to upper/lower lip center distance
- When the smile index crosses a configurable threshold, the current playback timestamp is appended to the `joyPins` array

### 5.4 `ThemeAnalyzerService`

A singleton wrapper around the custom CoreML model.

- Accepts the full transcript string as input
- Passes the text to `EchoThemeClassifier.mlmodel` via an `NLModel` wrapper
- Returns the predicted `ThemeCategory` label
- Falls back to `"Wisdom"` if the prediction confidence is below a minimum threshold or if the transcript is too short to classify reliably

### 5.5 `StorageManager`

The filesystem layer. Responsible for all permanent file operations.

- **`moveAudioToDocuments(_:)`**: Moves the temporary recording from `tmp` to the `DocumentDirectory`
- **`saveImage(_:filename:)`**: Persists cover photos and avatars as JPEG files
- **`loadImage(filename:)`**: Retrieves `UIImage` from the documents directory by filename
- **`seedAvatar(fromAssetName:)`**: Copies bundled seed images to the documents directory on first launch for demo data
- All methods return the filename (not the full path) to keep the SwiftData models lightweight

### 5.6 `CaptureSessionManager`

The orchestrator for the recording screen. It coordinates `AudioRecorderManager`, `TranscriptionService`, `FaceTrackingService`, and `CameraStreamService` through the full recording lifecycle: start → monitor → stop → process → save.

### 5.7 `BiometricAuthService`

A thin wrapper around `LAContext`. It evaluates a biometric policy (`deviceOwnerAuthenticationWithBiometrics`) and publishes an `isAuthenticated` boolean. This service is only activated if the user has enabled vault protection in Settings.

---

## 6. Application Flow

### 6.1 First-Run Onboarding Sequence

The `MainTabView` implements a finite state machine (`SequenceState`) to manage the first-run experience:

```
.boarding → .introKindle → .firstCapture → .completed
```

1. **`.boarding`** — Displays `OnboardingView` (3-slide walkthrough: Welcome animation, Privacy features, Get Started CTA)
2. **`.introKindle`** — Displays `KindleView` in onboarding mode with a guiding question prompt deck
3. **`.firstCapture`** — Launches `CaptureView` with `startImmediately: true` and the selected onboarding prompt
4. **`.completed`** — Transitions to the main app shell. `hasCompletedOnboarding` is persisted to `UserDefaults`

Returning users skip the sequence entirely; they see a `SplashScreenView` with a 2.5-second animated delay before the main app appears.

### 6.2 Complete Recording Lifecycle

The following describes the exact technical pipeline when a user creates one Echo:

1. **Permissions & Setup:** `CaptureView` requests microphone and camera permissions. `CaptureSessionManager` initializes all services.
2. **Recording Start:** `AudioRecorderManager` activates the `AVAudioSession` and begins writing a `.m4a` file to the `tmp` directory. The decibel metering timer fires at 60fps, driving the waveform UI.
3. **Real-Time Emotion Detection:** `CameraStreamService` feeds camera frames to `FaceTrackingService`. Vision's landmark detector scores each frame for a smile ratio; timestamps exceeding the smile threshold are appended to `joyPins`.
4. **Recording Stop:** The user taps stop. `AudioRecorderManager` finalizes the `.m4a` file.
5. **Transcription:** `TranscriptionService` reads the audio file and streams PCM chunks to `SFSpeechRecognizer`. The complete transcript string is returned.
6. **Theme Classification:** `ThemeAnalyzerService` feeds the transcript to `EchoThemeClassifier.mlmodel` and returns a theme label.
7. **Permanent Storage:** `StorageManager` moves the audio file from `tmp` to `DocumentDirectory`.
8. **Database Persistence:** A new `Echo` object is constructed and inserted into the `ModelContext`. The SwiftData context is saved. The Echo appears immediately in the Library.

### 6.3 Navigation Structure

The main app uses a custom floating tab bar rather than a standard `UITabBar`. Navigation paths:

| Tab | View | Purpose |
|---|---|---|
| Kindle (center-left) | `KindleView` | Swipeable prompt deck, default landing tab |
| Capture (center) | `CaptureView` (full screen cover) | Recording screen |
| Library (center-right) | `LibraryView` | All recorded Echoes, filterable by theme |
| Orbit (circle button) | `OrbitView` | Statistics, streaks, category breakdown |

Settings, Speaker Profiles, and Playback are presented as sheets or pushed views within these primary tabs.

---

## 7. NeoRetro Design System

All visual styling flows from a custom **NeoRetro** design system defined in the `Theme/` directory.

- **Color Palette:** A warm, tactile palette including `neoBackground` (warm cream), `neoInk` (near-black), `neoPrimary` (orange-amber), `neoMint`, `neoLilac`, `neoMustard`, and `neoCharcoal`
- **Typography:** System serif fonts (`design: .serif`) for headlines; weighted system sans-serif for body
- **Component Style:** `NeoRetroCardModifier` applies a characteristic 2pt black border with a hard drop shadow offset, giving UI elements a tactile, handmade quality
- **Buttons:** `NeoRetroButtonStyle` and `LiquidButton` provide consistent interactive affordances
- **Reusability:** All colors are defined as SwiftUI `Color` extensions, making them available globally throughout the view hierarchy without imports

---

## 8. Sample Data Seeding

On the very first launch, `EchoesApp` seeds the SwiftData store with 7 pre-built `Echo` objects and 8 `SpeakerProfile` objects to give judges and new users a rich, populated experience immediately.

The seed is gated behind a `UserDefaults` boolean key (`hasSeededSampleData`). Once set, the seed task never runs again. The seeded Echoes span all primary theme categories (Romance, Childhood, Wisdom, Family, Travel, Home) and include realistic transcripts, joy pin timestamps, and speaker attributions.

---

## 9. Potential Improvements & Technical Debt

### Architecture & Code Quality

- **Dependency Injection:** Many services use the Singleton pattern (`StorageManager.shared`, `ThemeAnalyzerService.shared`). Adopting a formal DI container or SwiftUI `Environment` injection would decouple services from views and make unit testing viable.
- **Strict MVVM:** Some views hold logic that would be better placed in an explicit `ViewModel`. `CaptureView` in particular coordinates across several services and would benefit from a dedicated `CaptureViewModel`.
- **Error Handling:** Service failures (audio parse errors, CoreML confidence failures) currently print to the console. A global, user-visible error notification system is needed.
- **Unit & Integration Tests:** No automated tests currently exist. The service layer is the highest-priority target for test coverage.

### Feature Enhancements (Strictly Offline)

- **Background Transcription:** Long recordings require the user to wait on-screen. `BGTaskScheduler` could process transcription in the background after the user leaves the app.
- **Advanced Face Tracking:** The current geometric smile detection could be enhanced with `ARFaceAnchor` (TrueDepth camera), enabling richer emotional data such as raised brows (surprise) or furrowed brows (concentration).
- **Full-Text Search:** `CoreSpotlight` or an offline SQLite FTS5 index would enable searching transcripts across the entire library, which becomes critical as the library grows.
- **Data Export & Backup:** An export feature (zipping the SwiftData SQLite store + Documents directory) to iCloud Drive or via the system share sheet is essential to prevent data loss from device failure.
- **Audio Compression:** `AVAssetExportSession` could be used offline to re-compress idle Echoes at lower bitrates, reducing long-term storage consumption.
- **iCloud Sync (Optional, Off by Default):** A future "sync" mode could use CloudKit's private database to replicate Echoes across a user's own devices, while keeping the strict no-server-sharing privacy guarantee.
