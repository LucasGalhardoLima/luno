# Implementation Plan: Voice-First Notes with PARA Categorization

**Branch**: `001-voice-notes-para` | **Date**: 2026-02-04 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-voice-notes-para/spec.md`

## Summary

Build a minimalist iOS note-taking app that prioritizes voice capture with real-time transcription, automatically categorizes notes using AI according to the PARA method (Projects, Areas, Resources, Archive), and presents notes through a three-screen navigation: Capture (blank notebook page), Notes (floating cards), and Folders (PARA organization). The app uses Apple's on-device Foundation Models for categorization with Claude API fallback, stores data locally with optional iCloud sync, and features polished micro-transitions throughout.

## Technical Context

**Language/Version**: Swift 5.9+ with SwiftUI
**Primary Dependencies**: SwiftUI, Speech framework, Foundation Models (Apple), SwiftData, Combine
**Storage**: SwiftData with optional CloudKit sync (local-first, iCloud opt-in)
**Testing**: XCTest (unit), XCUITest (UI), swift-snapshot-testing (snapshots)
**Target Platform**: iOS 17.0+ for SwiftData/base features; iOS 26+ for Foundation Models (on-device LLM)
**Project Type**: Mobile (iOS single app)
**Performance Goals**: App launch <400ms, transcription visible <3s, 60fps animations, categorization <2s
**Constraints**: Offline-capable for capture/browse/local-categorization; cloud categorization requires network
**Scale/Scope**: Personal productivity app, single user, local-first with optional sync

### Key Technology Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| UI Framework | SwiftUI | Constitution mandate; modern declarative UI |
| Speech Recognition | Apple Speech framework | Offline support, privacy, no third-party dependency |
| Local Storage | SwiftData + CloudKit | iOS 17+ modern persistence, optional iCloud sync |
| On-Device AI | Foundation Models (@Generable) | Apple's LLM for privacy-first categorization |
| Cloud AI Fallback | Claude API (Anthropic) | When on-device confidence <80% |
| Animations | Native SwiftUI | spring(), matchedGeometryEffect, PhaseAnimator |
| Architecture | MVVM + Repository + Services | Constitution mandate for testability |

### AI Categorization Strategy

```
┌─────────────────┐
│  Note Content   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│  Foundation Models      │
│  (On-Device, iOS 26+)   │
└────────┬────────────────┘
         │
         ▼
    confidence >= 80%?
         │
    ┌────┴────┐
   YES       NO
    │         │
    ▼         ▼
┌────────┐  ┌─────────────────┐
│ Accept │  │ Claude API      │
│ Result │  │ (Cloud Fallback)│
└────────┘  └────────┬────────┘
                     │
                     ▼
              ┌─────────────┐
              │ Save to     │
              │ Training DB │
              │ (improve    │
              │ on-device)  │
              └─────────────┘
```

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Test-First Development (NON-NEGOTIABLE)
- [x] **Plan includes test strategy**: Unit tests for services, UI tests for flows, snapshot tests for cards
- [x] **TDD workflow planned**: Tests written before implementation per task structure
- [x] **Coverage targets defined**: 70% new code, 80% business logic (categorization service)

### II. Native iOS Excellence
- [x] **SwiftUI primary**: All UI in SwiftUI
- [x] **Platform conventions**: Speech framework, SwiftData, Foundation Models, Combine
- [x] **iOS version support**: iOS 17+ base, iOS 26+ for full AI features
- [x] **System settings respected**: Dynamic Type, Dark Mode, VoiceOver, Reduce Motion

### III. User Experience Quality
- [x] **Performance targets**: <400ms launch, <3s transcription, 60fps animations
- [x] **Offline capability**: Voice capture + local categorization work offline
- [x] **Accessibility**: VoiceOver, 44pt touch targets, contrast requirements
- [x] **Error states**: Defined in edge cases (retry, queue, fallback)
- [x] **Micro-transitions**: Spring animations, matched geometry effects planned

### IV. Code Architecture
- [x] **MVVM pattern**: Views → ViewModels → Services → Repository
- [x] **Dependency injection**: Protocol-based services for testability
- [x] **Repository abstraction**: NoteRepository protocol over SwiftData
- [x] **No business logic in Views**: Categorization in service layer

### V. Simplicity & Pragmatism
- [x] **Minimal dependencies**: Apple frameworks primarily; Claude SDK justified for fallback
- [x] **YAGNI applied**: No multi-language, no export, no sharing in v1
- [x] **Feature focus**: Three screens, one entity type, focused scope

**Constitution Check: PASSED** - No violations requiring justification.

## Project Structure

### Documentation (this feature)

```text
specs/001-voice-notes-para/
├── plan.md              # This file
├── research.md          # Phase 0 - Technology research findings
├── data-model.md        # Phase 1 - SwiftData model definitions
├── quickstart.md        # Phase 1 - Developer setup guide
├── contracts/           # Phase 1 - Service protocol definitions
│   ├── NoteRepositoryProtocol.swift
│   ├── SpeechServiceProtocol.swift
│   ├── CategorizationServiceProtocol.swift
│   └── SyncServiceProtocol.swift
├── checklists/
│   └── requirements.md  # Specification validation
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
Luno/
├── App/
│   ├── LunoApp.swift              # App entry, DI container setup
│   ├── AppState.swift             # Global app state, sync status
│   └── ContentView.swift          # Root TabView navigation
│
├── Features/
│   ├── Capture/
│   │   ├── CaptureView.swift      # Blank notebook capture screen
│   │   ├── CaptureViewModel.swift # Voice/text capture orchestration
│   │   ├── VoiceRecorderView.swift # Recording UI with waveform
│   │   └── CategorizationSheet.swift # AI suggestion confirmation
│   │
│   ├── Notes/
│   │   ├── NotesView.swift        # All notes floating cards grid
│   │   ├── NotesViewModel.swift   # Notes list + filtering
│   │   └── NoteCardView.swift     # Floating card component
│   │
│   ├── Folders/
│   │   ├── FoldersView.swift      # PARA folders screen
│   │   ├── FoldersViewModel.swift # Folder navigation
│   │   ├── FolderCardView.swift   # Folder card with count
│   │   └── FolderNotesView.swift  # Notes within a folder
│   │
│   └── NoteDetail/
│       ├── NoteDetailView.swift   # Full note view/edit
│       ├── NoteDetailViewModel.swift
│       └── CategoryPickerView.swift # Re-categorization UI
│
├── Core/
│   ├── Models/
│   │   ├── Note.swift             # SwiftData @Model
│   │   ├── PARACategory.swift     # Enum + @Generable
│   │   ├── CategorizationResult.swift # AI response structure
│   │   └── TrainingExample.swift  # Fallback training data
│   │
│   ├── Services/
│   │   ├── SpeechService.swift    # Apple Speech wrapper
│   │   ├── CategorizationService.swift # AI orchestration
│   │   ├── OnDeviceCategorizationService.swift # Foundation Models
│   │   ├── ClaudeCategorizationService.swift # API fallback
│   │   ├── SyncService.swift      # iCloud sync management
│   │   └── Protocols/
│   │       ├── SpeechServiceProtocol.swift
│   │       ├── CategorizationServiceProtocol.swift
│   │       └── SyncServiceProtocol.swift
│   │
│   └── Repository/
│       ├── NoteRepository.swift   # SwiftData implementation
│       ├── TrainingRepository.swift # Store fallback examples
│       └── NoteRepositoryProtocol.swift
│
├── Shared/
│   ├── Components/
│   │   ├── FloatingCard.swift     # Reusable card with shadow
│   │   ├── RecordButton.swift     # Animated record button
│   │   └── CategoryBadge.swift    # PARA category indicator
│   │
│   ├── Animations/
│   │   └── MicroTransitions.swift # Shared animation configs
│   │
│   ├── Extensions/
│   │   ├── View+Animations.swift
│   │   └── Date+Formatting.swift
│   │
│   └── Theme/
│       ├── LunoTheme.swift        # Colors, typography, spacing
│       └── LunoColors.swift       # PARA category colors
│
└── Resources/
    ├── Assets.xcassets
    ├── Localizable.strings
    └── Info.plist

LunoTests/
├── Unit/
│   ├── Services/
│   │   ├── CategorizationServiceTests.swift
│   │   ├── OnDeviceCategorizationTests.swift
│   │   └── SpeechServiceTests.swift
│   ├── ViewModels/
│   │   ├── CaptureViewModelTests.swift
│   │   ├── NotesViewModelTests.swift
│   │   └── FoldersViewModelTests.swift
│   └── Repository/
│       └── NoteRepositoryTests.swift
│
├── Integration/
│   ├── CategorizationFlowTests.swift
│   └── SyncServiceTests.swift
│
└── Snapshots/
    ├── NoteCardViewSnapshotTests.swift
    ├── FolderCardViewSnapshotTests.swift
    └── CaptureViewSnapshotTests.swift

LunoUITests/
├── CaptureFlowUITests.swift
├── NotesNavigationUITests.swift
└── CategorizationUITests.swift
```

**Structure Decision**: Feature-based iOS app organization. Each feature (Capture, Notes, Folders, NoteDetail) contains its own View/ViewModel pair. Core contains shared models, services with protocol abstractions, and repository layer. Shared holds reusable UI components and theme. This structure enables independent feature development aligned with user story priorities.

## Complexity Tracking

> No violations - Constitution Check passed without exceptions.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | N/A | N/A |

## Dependencies

### Apple Frameworks (No Package Required)
- SwiftUI
- SwiftData
- Speech
- Foundation Models (iOS 26+)
- CloudKit
- Combine

### External Dependencies (Swift Package Manager)

```swift
// Package.swift dependencies
dependencies: [
    // Claude API client
    .package(url: "https://github.com/anthropics/anthropic-sdk-swift", from: "1.0.0"),

    // Snapshot testing (dev only)
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.0"),
]
```

**Justification for Claude SDK**: Required for AI fallback when on-device categorization confidence is below 80%. This is a core feature requirement, not premature complexity.
