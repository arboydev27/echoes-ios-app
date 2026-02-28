# Echoes

A privacy-first iOS application for capturing, transcribing, and preserving personal audio memories — entirely on-device, with no cloud dependency.

---

## Table of Contents

- [What is Echoes?](#what-is-echoes)
- [Core Features](#core-features)
- [Technology Stack](#technology-stack)
- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Requirements](#requirements)
- [App Navigation](#app-navigation)
- [The Recording Pipeline](#the-recording-pipeline)
- [Data & Privacy Model](#data--privacy-model)
- [Design System](#design-system)
- [Further Reading](#further-reading)

---

## What is Echoes?

Echoes is an iPhone application built for capturing the personal stories of the people in your life. It guides speakers through curated memory prompts — covering themes like childhood, romance, family, and wisdom — and records their spoken responses as high-quality audio memories called Echoes.

What makes Echoes distinct is its commitment to privacy and local intelligence. Every feature — speech transcription, smile detection, and theme classification — runs entirely on the iPhone using Apple's on-device machine learning frameworks. No microphone audio, transcript, or personal data is transmitted to any server at any time.

---

## Core Features

**Guided Story Prompts (Kindle)**
A swipeable, card-based deck of 24 story prompts organized across 8 thematic categories. Speakers can browse prompts by theme and select one to anchor their recording session.

**Audio Recording**
Records memories as M4A audio files with real-time decibel visualization. Two quality settings are available: High Fidelity (128kbps AAC) and Space Saver (64kbps AAC), with Space Saver set as the default to balance quality with long-term storage efficiency.

**On-Device Transcription**
After each recording, the full audio is transcribed entirely on-device using Apple's Speech framework. The transcript powers the in-app "Memory Snippet" preview and the CoreML theme classifier. A custom PCM buffer streaming technique is used to bypass Apple's standard ~15-second URL-transcription limit, ensuring arbitrarily long recordings are fully transcribed.

**Emotion Detection ("Joy Pins")**
During recording, the front-facing camera captures facial landmarks in real time using the Vision framework. A geometric smile index — calculated from the ratio of mouth corner distance to lip height — is evaluated on every frame. When a smile is detected, the current audio timestamp is saved as a "joy pin." These timestamps are later visualized on the playback timeline so listeners can pinpoint moments of genuine emotion.

**Theme Classification**
Once transcription is complete, the resulting text is passed to a custom CoreML model (`EchoThemeClassifier.mlmodel`) trained to categorize memories into one of eight themes: Childhood, Romance, Family, Travel, Home, Lessons, Wisdom, or Work. If the model's confidence is below a minimum threshold, the memory defaults to the "Wisdom" category.

**Memory Library**
A filterable grid of all recorded Echoes. Memories can be sorted and filtered by theme category, marked as favorites, and attributed to named speakers with custom avatar photos.

**Playback**
A dedicated playback screen shows the memory's transcript, its joy pin timestamps overlaid on an audio scrubber, and the speaker's profile. The full audio plays back via a local AVAudioPlayer instance.

**Orbit Dashboard**
A visual statistics view showing recording streaks, total hours of audio captured, and a breakdown of memory themes. Streak calculations are handled by `OrbitViewModel`, which processes the SwiftData query results to produce daily and weekly streak data.

**Speaker Profiles**
Named profiles for each person whose voice appears in the library, each with an optional custom avatar photo. Profiles are stored in SwiftData and linked to Echoes by speaker name.

**Biometric Vault Protection**
Optional Face ID or Touch ID protection via the LocalAuthentication framework. When enabled, the app requires biometric authentication on each launch before displaying the memory library.

---

## Technology Stack

| Layer | Technology | Notes |
|---|---|---|
| UI Framework | SwiftUI | Exclusive — no UIKit view controllers |
| Local Persistence | SwiftData | Declarative models with `@Model` macro |
| Audio | AVFoundation | `AVAudioRecorder`, `AVAudioPlayer`, `AVAudioPCMBuffer` |
| Transcription | Speech (`SFSpeechRecognizer`) | On-device mode enforced; no network fallback |
| Face Tracking | Vision (`VNDetectFaceLandmarksRequest`) | Runs on every camera frame during recording |
| Theme ML | CoreML + NaturalLanguage (`NLModel`) | Custom trained `EchoThemeClassifier.mlmodel` |
| Reactivity | Observation (`@Observable`) | Used across all `@Observable` service classes |
| Authentication | LocalAuthentication | Face ID / Touch ID |
| Language | Swift 5.9+ | Concurrency via `async/await` and `Task` |
| Minimum OS | iOS 17.0 | Required for SwiftData + `@Observable` |

---

## Architecture Overview

Echoes follows a **MVVM + Service-Oriented Architecture**. The application is organized into three distinct layers:

**Models** define the data structures. `Echo` and `SpeakerProfile` are SwiftData `@Model` entities that persist to a local SQLite store. `Prompt` and `ThemeCategory` are pure Swift value types used for UI presentation and logic.

**Services** handle all side-effectful operations — I/O, hardware access, and machine learning inference. Each service is a single-responsibility, `@Observable` class. Services are instantiated and coordinated by `CaptureSessionManager` during the recording phase. Outside of capture, services like `ThemeAnalyzerService` and `StorageManager` are accessed as shared singletons.

**Views** are declarative SwiftUI components that observe services or local `@Observable` view models. Views contain no business logic; they invoke service methods and display observed state.

For a detailed technical breakdown of every service, data model, and the complete recording pipeline, see the [Architecture Guide](Echoes_Architecture_Guide.md).

---

## Project Structure

```
Echoes/
├── EchoesApp.swift              # App entry point, container setup, sample data seeding
├── Models/
│   ├── Echo.swift               # Primary SwiftData entity (one per recorded memory)
│   ├── SpeakerProfile.swift     # SwiftData entity for named speaker profiles
│   ├── Prompt.swift             # Prompt value type + 24-item static sample deck
│   ├── ThemeCategory.swift      # Theme enum (8 cases) with colors and SF Symbol icons
│   └── ML/
│       └── EchoThemeClassifier.mlmodel
├── Services/
│   ├── AudioRecorderManager.swift
│   ├── AudioPlayerManager.swift
│   ├── CameraStreamService.swift
│   ├── FaceTrackingService.swift
│   ├── TranscriptionService.swift
│   ├── ThemeAnalyzerService.swift
│   ├── StorageManager.swift
│   ├── CaptureSessionManager.swift
│   ├── RecordingManager.swift
│   └── BiometricAuthService.swift
├── Views/
│   ├── MainTabView.swift         # Root navigation + onboarding sequence state machine
│   ├── SplashScreenView.swift
│   ├── Onboarding/
│   ├── Kindle/
│   ├── Capture/
│   ├── Library/
│   ├── Playback/
│   ├── Orbit/
│   ├── Profile/
│   ├── Settings/
│   └── Components/
└── Theme/                       # NeoRetro design system (colors, styles, modifiers)
```

---

## Getting Started

### Prerequisites

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- An iOS 17.0+ device or simulator (a physical device is recommended for microphone and camera features)

### Setup

1. Clone this repository.
2. Open `Echoes.xcodeproj` in Xcode.
3. Select your development team in the project's Signing & Capabilities settings.
4. Choose your target device (physical iPhone recommended for full feature access).
5. Press `Cmd + R` to build and run.

**Note:** On first launch, the app automatically seeds the SwiftData store with 7 pre-built Echoes and 8 speaker profiles so the app immediately demonstrates a rich, populated state for testing and evaluation. This seed runs only once and is gated by a `UserDefaults` flag (`hasSeededSampleData`).

---

## Requirements

| Requirement | Version |
|---|---|
| Xcode | 15.0 or later |
| iOS Deployment Target | 17.0 or later |
| Swift | 5.9 or later |
| Physical device | Recommended for microphone, camera, and Face ID |

The following device permissions are requested at runtime:

- **Microphone** — Required for audio recording
- **Camera** — Required for smile (joy pin) detection during recording
- **Speech Recognition** — Required for on-device transcription
- **Face ID / Touch ID** — Optional; only requested if the user enables biometric vault protection in Settings

---

## App Navigation

The main application uses a custom floating tab bar (not a standard `UITabBar`). The bar contains three primary destinations in a pill-shaped container and a separate circular Orbit button.

| Destination | Description |
|---|---|
| Kindle | The default landing screen; a swipeable deck of story prompts. Selecting a prompt leads directly to the Capture screen. |
| Capture | The recording screen, presented as a full-screen cover. Contains live waveform visualization, a timer, and smile detection indicators. |
| Library | A grid of all recorded Echoes. Filter chips at the top allow filtering by theme category or favorites. Tapping an Echo opens Playback. |
| Orbit | The statistics dashboard. Displays recording streaks, total hours, and a thematic breakdown of the library. |

On the very first launch, users are guided through a linear onboarding sequence before reaching the main tab bar:

```
Onboarding (3-slide walkthrough) → Kindle (prompt selection) → Capture (first recording) → Library
```

---

## The Recording Pipeline

The following describes the technical sequence when a user creates an Echo:

1. **Permissions** — `CaptureView` requests microphone and camera access. `CaptureSessionManager` initializes all services.
2. **Recording** — `AudioRecorderManager` activates the `AVAudioSession` and begins writing a `.m4a` file to the device's `tmp` directory. Decibel levels are sampled at 60fps to animate the waveform.
3. **Smile Detection** — `CameraStreamService` delivers camera frames to `FaceTrackingService`, which runs `VNDetectFaceLandmarksRequest` on each frame. Frames that exceed the smile threshold append the current timestamp to a `joyPins` array.
4. **Stop** — The user ends the recording. `AudioRecorderManager` finalizes the `.m4a` file.
5. **Transcription** — `TranscriptionService` streams the audio through an `AVAudioPCMBuffer` into `SFSpeechRecognizer` to produce a full transcript on-device.
6. **Classification** — `ThemeAnalyzerService` passes the transcript to `EchoThemeClassifier.mlmodel` and returns the predicted theme label.
7. **Storage** — `StorageManager` moves the `.m4a` file from `tmp` to the permanent `DocumentDirectory`.
8. **Persistence** — A new `Echo` object is inserted into the SwiftData `ModelContext` and saved. The memory appears immediately in the Library.

---

## Data & Privacy Model

Echoes is designed around an absolute privacy guarantee: **no user data, audio, transcript, or personal information is ever transmitted off the device**.

| Data Type | Storage Location | Notes |
|---|---|---|
| Echo metadata | SwiftData SQLite store | Title, transcript, theme, joy pins, date, duration |
| Audio files | App Documents directory | `.m4a` files referenced by filename string in SwiftData |
| Cover images | App Documents directory | JPEG files referenced by filename string in SwiftData |
| Speaker avatars | App Documents directory | JPEG files referenced by filename string in SwiftData |
| App preferences | `UserDefaults` | Onboarding state, seed flag, settings toggles |

Heavy binary assets are stored on the filesystem and referenced by filename rather than as binary blobs in the database. This design keeps the SwiftData store small and prevents memory pressure during large library fetches.

There is no network layer, no telemetry, no authentication backend, and no third-party SDKs. All ML inference uses Apple's on-device CoreML and Speech frameworks.

---

## Design System

All visuals flow from a custom **NeoRetro** design system defined in the `Theme/` directory.

**Color Palette**
A warm, tactile palette of named semantic colors available globally as SwiftUI `Color` extensions: `neoBackground` (warm cream), `neoInk` (near-black), `neoPrimary` (orange-amber), `neoMint`, `neoLilac`, `neoMustard`, and `neoCharcoal`.

**Component Style**
`NeoRetroCardModifier` applies a 2pt black border with a hard 4pt drop shadow offset, giving cards a printed, tactile quality. Buttons use `NeoRetroButtonStyle` for a consistent interactive affordance.

**Typography**
Display text uses SwiftUI's system serif design (`Font.system(design: .serif)`) for a classic, editorial feel. Supporting text uses weighted system sans-serif.

**Theme Colors**
Each `ThemeCategory` case is assigned a distinct pastel color used consistently across prompt cards, filter chips, and the Orbit dashboard: Tangerine, Bubblegum, Sage, Turquoise, Lilac, and Lavender.

---

## Further Reading

For a deep technical reference, including full service API descriptions, the complete recording lifecycle diagram, the onboarding state machine, and a list of known technical debt, see the [Architecture Guide](Echoes_Architecture_Guide.md).
