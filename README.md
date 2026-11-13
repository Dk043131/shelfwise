# Shelfwise (iOS) — Intelligent Curriculum & Visual Reading Tracker 📚

[![iOS](https://img.shields.io/badge/iOS-17.0+-000000?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?logo=swift&logoColor=white)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-007AFF?logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![Combine](https://img.shields.io/badge/Combine-Reactive-FF9500?logo=apple&logoColor=white)](https://developer.apple.com/documentation/combine)
[![AVFoundation](https://img.shields.io/badge/AVFoundation-Camera_Vault-34C759?logo=apple&logoColor=white)](https://developer.apple.com/av-foundation/)
[![OpenLibrary API](https://img.shields.io/badge/OpenLibrary-Book_Search-000000?logo=internetarchive&logoColor=white)](https://openlibrary.org/developers/api)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **Shelfwise** is an intelligent reading companion and curriculum tracker built natively for iOS with **Swift**, **SwiftUI**, **Combine**, and **AVFoundation**. It combines real-time book metadata discovery via the **OpenLibrary API**, an encrypted **AVFoundation-based Visual Notes Vault**, a **7-day habit analytics dashboard**, and a bespoke **Liquid Glass dark-mode UI**.

---

## 🌟 Key Highlights

- **Intelligent Curriculum Engine**: Structured multi-level reading paths spanning Cognitive Psychology, Mental Models, Behavioural Economics, and Subconscious Processes.
- **OpenLibrary API Integration**: Asynchronous title, author, cover, page count, and key insight lookup (`BookLookupService`) with automatic metadata fallback and topic classification.
- **AVFoundation Visual Notes Vault**: Capture book annotations, margin notes, and physical page excerpts directly into an organized visual vault (`CameraView` & `PhotoNotesView`).
- **7-Day Analytics & Velocity Dashboard**: Interactive reading streak tracking, daily page metrics, topic completion ratios, and reading habit insights (`WeeklyReportView`).
- **Custom Liquid Glass Dark UI**: Glassmorphic styling, neon accent gradients, and smooth interactive spring animations designed for deep focus (`Theme.swift`).

---

## 🏗️ System Architecture

```mermaid
flowchart TD
    User([Reader]) -->|Interacts with UI| View[SwiftUI Liquid Glass Interface]
    View -->|Search Query| Lookup[BookLookupService / URLSession]
    Lookup -->|Fetch Metadata & Covers| OpenLib[OpenLibrary REST API]
    View -->|Capture Margin Notes| Camera[AVFoundation Camera Engine]
    Camera -->|Store Annotations| PhotoVault[Visual Notes Vault]
    View -->|Log Pages Read| DataMgr[DataManager State Store]
    DataMgr -->|Compute Velocity & Streaks| Analytics[7-Day Analytics Engine]
    DataMgr -->|Schedule Reading Alarms| Notif[NotificationManager]
```

---

## 🚀 Feature Details

### 1. Intelligent Curriculum Catalog
- Guided progression through curated psychology and self-mastery topics.
- Tracks reading milestone percentages per subject topic.
- Dynamic custom book addition with tag and curriculum binding.

### 2. OpenLibrary Network Client
- Queries `openlibrary.org/search.json` with rate-limiting, error recovery, and image caching.
- Extracts author details, published editions, and high-resolution cover artwork.

### 3. AVFoundation Visual Notes Vault
- Custom hardware camera session management with real-time preview and flash controls.
- Tag visual excerpts by chapter, page number, and key quote takeaways.

### 4. 7-Day Velocity & Habit Dashboard
- Daily reading streaks with completion rings.
- Visual breakdown of pages logged versus weekly reading targets.

---

## 📂 Project Structure

```
Shelfwise/
├── Shelfwise.xcodeproj/           # Xcode Project
├── book_covers/                   # High-res curated cover assets
└── Shelfwise/
    ├── MyApp.swift                # App entrypoint
    ├── Models.swift               # Data models & Psychology topics
    ├── DataManager.swift          # Core data controller & persistence
    ├── BookLookupService.swift    # OpenLibrary API client
    ├── Theme.swift                # Glassmorphic Liquid Glass design tokens
    ├── ContentView.swift          # Root navigation & tab bar
    ├── BookCardView.swift         # Fluid book cover cards
    ├── BookDetailView.swift       # Reading status & chapter milestones
    ├── CurriculumCatalog.swift    # Structured curriculum definitions
    ├── CurriculumView.swift       # Topic roadmap & skill tracking
    ├── CameraView.swift           # AVFoundation camera capture
    ├── PhotoNotesView.swift       # Visual notes gallery & notes vault
    ├── WeeklyReportView.swift     # 7-day analytics charts
    ├── NotificationManager.swift  # Reading reminder dispatcher
    └── Assets.xcassets/           # Colors and app assets
```

---

## 🛠️ Building & Running

### Requirements
- macOS Sonoma or Sequoia
- Xcode 15.0+ or Xcode 16+
- iOS 17.0+ Simulator or physical device

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/Dk043131/shelfwise.git
   cd shelfwise
   ```
2. Open the project in Xcode:
   ```bash
   open Shelfwise.xcodeproj
   ```
3. Select an iOS 17+ Simulator or your connected iPhone.
4. Press `Cmd + R` to build and run.

---

## 📄 License
This project is open-source under the [MIT License](LICENSE).
