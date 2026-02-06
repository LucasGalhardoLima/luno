# Tasks: Voice-First Notes with PARA Categorization

**Input**: Design documents from `/specs/001-voice-notes-para/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: TDD is **MANDATORY** per project constitution. Tests must be written FIRST and FAIL before implementation.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **iOS App**: `Luno/` at repository root
- **Unit Tests**: `LunoTests/Unit/`
- **Integration Tests**: `LunoTests/Integration/`
- **Snapshot Tests**: `LunoTests/Snapshots/`
- **UI Tests**: `LunoUITests/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create Xcode project "Luno" with SwiftUI App template targeting iOS 17.0+
- [x] T002 Configure project capabilities: Speech Recognition, iCloud (CloudKit), Background Modes
- [x] T003 [P] Add Swift Package dependencies: anthropic-sdk-swift, swift-snapshot-testing
- [x] T004 [P] Configure SwiftLint with project rules in `.swiftlint.yml`
- [x] T005 [P] Configure SwiftFormat with project rules in `.swiftformat`
- [x] T006 Create folder structure per plan.md: App/, Features/, Core/, Shared/, Resources/
- [x] T007 [P] Create LunoTheme.swift with colors, typography, spacing constants in Luno/Shared/Theme/
- [x] T008 [P] Create LunoColors.swift with PARA category colors in Luno/Shared/Theme/
- [x] T009 [P] Create MicroTransitions.swift with shared animation configurations in Luno/Shared/Animations/
- [x] T010 [P] Add Info.plist keys: NSSpeechRecognitionUsageDescription, NSMicrophoneUsageDescription

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Tests for Foundational Phase

- [x] T011 [P] Unit tests for Note model validation in LunoTests/Unit/Models/NoteTests.swift
- [x] T012 [P] Unit tests for PARACategory enum in LunoTests/Unit/Models/PARACategoryTests.swift
- [x] T013 [P] Unit tests for NoteRepository CRUD operations in LunoTests/Unit/Repository/NoteRepositoryTests.swift

### Implementation for Foundational Phase

- [x] T014 [P] Create PARACategory.swift enum with @Generable in Luno/Core/Models/
- [x] T015 [P] Create NoteSourceType.swift enum in Luno/Core/Models/
- [x] T016 Create Note.swift SwiftData @Model in Luno/Core/Models/ (depends on T014, T015)
- [x] T017 [P] Create NoteRepositoryProtocol.swift in Luno/Core/Repository/
- [x] T018 Create NoteRepository.swift SwiftData implementation in Luno/Core/Repository/ (depends on T016, T017)
- [x] T019 Create AppState.swift for global app state in Luno/App/
- [x] T020 Create LunoApp.swift with ModelContainer and DI setup in Luno/App/ (depends on T016, T018)
- [x] T021 Create ContentView.swift with TabView (Capture, Notes, Folders) in Luno/App/ (depends on T020)
- [x] T022 [P] Create FloatingCard.swift reusable component in Luno/Shared/Components/
- [x] T023 [P] Create CategoryBadge.swift component in Luno/Shared/Components/
- [x] T024 [P] Create View+Animations.swift extensions in Luno/Shared/Extensions/
- [x] T025 [P] Create Date+Formatting.swift extensions in Luno/Shared/Extensions/

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Voice Note Capture (Priority: P1) 🎯 MVP

**Goal**: Users can quickly capture thoughts using voice with real-time transcription

**Independent Test**: Tap record, speak a note, see transcription appear in real-time, review and save

### Tests for User Story 1 (TDD - Write First, Must Fail)

- [x] T026 [P] [US1] Unit tests for SpeechService in LunoTests/Unit/Services/SpeechServiceTests.swift
- [x] T027 [P] [US1] Unit tests for CaptureViewModel in LunoTests/Unit/ViewModels/CaptureViewModelTests.swift
- [x] T028 [P] [US1] Snapshot tests for RecordButton states in LunoTests/Snapshots/RecordButtonSnapshotTests.swift
- [x] T029 [US1] UI tests for voice capture flow in LunoUITests/CaptureFlowUITests.swift

### Implementation for User Story 1

- [x] T030 [P] [US1] Create SpeechServiceProtocol.swift in Luno/Core/Services/Protocols/
- [x] T031 [US1] Implement SpeechService.swift with Apple Speech framework in Luno/Core/Services/ (depends on T030)
- [x] T032 [P] [US1] Create RecordButton.swift animated component in Luno/Shared/Components/
- [x] T033 [P] [US1] Create VoiceRecorderView.swift with waveform feedback in Luno/Features/Capture/
- [x] T034 [US1] Create CaptureViewModel.swift with voice capture logic in Luno/Features/Capture/ (depends on T031)
- [x] T035 [US1] Create CaptureView.swift blank notebook interface in Luno/Features/Capture/ (depends on T032, T033, T034)
- [x] T036 [US1] Add speech permission request flow to CaptureView
- [x] T037 [US1] Implement 2-second pause auto-stop in SpeechService
- [x] T038 [US1] Add transcription editing before save in CaptureView
- [x] T039 [US1] Connect CaptureView to NoteRepository for saving notes (depends on T018)

**Checkpoint**: Voice capture MVP complete - users can record, transcribe, and save voice notes

---

## Phase 4: User Story 2 - AI-Powered PARA Categorization (Priority: P2)

**Goal**: App automatically suggests PARA category for each note with confidence indicator

**Independent Test**: Create note, see AI suggestion with reasoning, accept/change/defer categorization

### Tests for User Story 2 (TDD - Write First, Must Fail)

- [x] T040 [P] [US2] Unit tests for OnDeviceCategorizationService in LunoTests/Unit/Services/OnDeviceCategorizationTests.swift
- [x] T041 [P] [US2] Unit tests for ClaudeCategorizationService in LunoTests/Unit/Services/ClaudeCategorizationTests.swift
- [x] T042 [P] [US2] Unit tests for CategorizationService orchestrator in LunoTests/Unit/Services/CategorizationServiceTests.swift
- [x] T043 [US2] Integration tests for categorization flow in LunoTests/Integration/CategorizationFlowTests.swift
- [x] T044 [US2] UI tests for categorization confirmation in LunoUITests/CategorizationUITests.swift

### Implementation for User Story 2

- [x] T045 [P] [US2] Create CategorizationResult.swift with @Generable in Luno/Core/Models/
- [x] T046 [P] [US2] Create TrainingExample.swift SwiftData model in Luno/Core/Models/
- [x] T047 [P] [US2] Create CategorizationServiceProtocol.swift in Luno/Core/Services/Protocols/
- [x] T048 [US2] Create TrainingRepository.swift for storing fallback examples in Luno/Core/Repository/ (depends on T046)
- [x] T049 [US2] Implement OnDeviceCategorizationService.swift with Foundation Models in Luno/Core/Services/ (depends on T045, T047)
- [x] T050 [US2] Implement ClaudeCategorizationService.swift with Anthropic SDK in Luno/Core/Services/ (depends on T045, T047)
- [x] T051 [US2] Implement CategorizationService.swift orchestrator with fallback logic in Luno/Core/Services/ (depends on T048, T049, T050)
- [x] T052 [US2] Create CategorizationSheet.swift confirmation UI in Luno/Features/Capture/ (depends on T051)
- [x] T053 [US2] Integrate CategorizationSheet into CaptureView after note save (depends on T039, T052)
- [x] T054 [US2] Implement confidence threshold check (80%) and fallback trigger in CategorizationService
- [x] T055 [US2] Store training examples when cloud fallback is used

**Checkpoint**: AI categorization complete - notes are auto-categorized with user confirmation

---

## Phase 5: User Story 3 - Text Input as Alternative (Priority: P3)

**Goal**: Users can type notes when voice isn't appropriate, with seamless switching

**Independent Test**: Type a note, save it, verify it goes through categorization flow

### Tests for User Story 3 (TDD - Write First, Must Fail)

- [x] T056 [P] [US3] Unit tests for text input in CaptureViewModel in LunoTests/Unit/ViewModels/CaptureViewModelTests.swift (extend existing)
- [x] T057 [US3] UI tests for text input flow in LunoUITests/CaptureFlowUITests.swift (extend existing)

### Implementation for User Story 3

- [x] T058 [US3] Add text input area to CaptureView.swift in Luno/Features/Capture/
- [x] T059 [US3] Implement voice/text toggle in CaptureViewModel
- [x] T060 [US3] Add seamless switching between voice and text without content loss
- [x] T061 [US3] Ensure text notes flow through same categorization as voice notes

**Checkpoint**: Alternative input complete - users can capture notes via voice OR typing

---

## Phase 6: User Story 4 - Browse All Notes (Priority: P4)

**Goal**: Users see all notes as floating cards with smooth animations

**Independent Test**: Create multiple notes, navigate to Notes tab, see all cards with category badges

### Tests for User Story 4 (TDD - Write First, Must Fail)

- [x] T062 [P] [US4] Unit tests for NotesViewModel in LunoTests/Unit/ViewModels/NotesViewModelTests.swift
- [x] T063 [P] [US4] Snapshot tests for NoteCardView in LunoTests/Snapshots/NoteCardViewSnapshotTests.swift
- [x] T064 [US4] UI tests for notes navigation in LunoUITests/NotesNavigationUITests.swift

### Implementation for User Story 4

- [x] T065 [P] [US4] Create NoteCardView.swift floating card component in Luno/Features/Notes/
- [x] T066 [US4] Create NotesViewModel.swift with query logic in Luno/Features/Notes/ (depends on T018)
- [x] T067 [US4] Create NotesView.swift with scrollable card grid in Luno/Features/Notes/ (depends on T065, T066)
- [x] T068 [US4] Add smooth scroll animations and depth effects to NotesView
- [x] T069 [US4] Implement card tap navigation to note detail
- [x] T070 [US4] Add category badge display on each NoteCardView

**Checkpoint**: Notes browsing complete - users can see all notes as floating cards

---

## Phase 7: User Story 5 - Browse Notes by PARA Folders (Priority: P5)

**Goal**: Users browse notes organized into PARA folders with note counts

**Independent Test**: Navigate to Folders tab, see 4 PARA folders with counts, tap to see filtered notes

### Tests for User Story 5 (TDD - Write First, Must Fail)

- [x] T071 [P] [US5] Unit tests for FoldersViewModel in LunoTests/Unit/ViewModels/FoldersViewModelTests.swift
- [x] T072 [P] [US5] Snapshot tests for FolderCardView in LunoTests/Snapshots/FolderCardViewSnapshotTests.swift
- [x] T073 [US5] UI tests for folder navigation in LunoUITests/FoldersNavigationUITests.swift

### Implementation for User Story 5

- [x] T074 [P] [US5] Create FolderCardView.swift with count badge in Luno/Features/Folders/
- [x] T075 [US5] Create FoldersViewModel.swift with category counts in Luno/Features/Folders/ (depends on T018)
- [x] T076 [US5] Create FoldersView.swift with 4 PARA folder cards in Luno/Features/Folders/ (depends on T074, T075)
- [x] T077 [US5] Create FolderNotesView.swift for filtered notes list in Luno/Features/Folders/
- [x] T078 [US5] Implement folder tap navigation to FolderNotesView
- [x] T079 [US5] Add archive action for notes in folder detail view

**Checkpoint**: Folder browsing complete - users can browse notes by PARA category

---

## Phase 8: User Story 6 - Quick Re-categorization (Priority: P6)

**Goal**: Users can change a note's category at any time from note detail view

**Independent Test**: View a note, tap category badge, select different category, verify it moves

### Tests for User Story 6 (TDD - Write First, Must Fail)

- [x] T080 [P] [US6] Unit tests for NoteDetailViewModel in LunoTests/Unit/ViewModels/NoteDetailViewModelTests.swift
- [x] T081 [P] [US6] Snapshot tests for CategoryPickerView in LunoTests/Snapshots/CategoryPickerSnapshotTests.swift
- [x] T082 [US6] UI tests for re-categorization flow in LunoUITests/RecategorizationUITests.swift

### Implementation for User Story 6

- [x] T083 [P] [US6] Create CategoryPickerView.swift with all PARA options in Luno/Features/NoteDetail/
- [x] T084 [US6] Create NoteDetailViewModel.swift in Luno/Features/NoteDetail/
- [x] T085 [US6] Create NoteDetailView.swift with edit and category change in Luno/Features/NoteDetail/ (depends on T083, T084)
- [x] T086 [US6] Implement category change persistence and immediate UI update
- [x] T087 [US6] Add category change option to CategorizationSheet for initial save flow

**Checkpoint**: Re-categorization complete - users can change note categories anytime

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Quality improvements that affect multiple user stories

- [ ] T088 [P] Run Accessibility Inspector audit on all screens
- [x] T089 [P] Add VoiceOver labels to all interactive elements
- [x] T090 [P] Implement Dynamic Type support across all text
- [x] T091 [P] Add Reduce Motion support to all animations
- [x] T092 [P] Snapshot tests for CaptureView in LunoTests/Snapshots/CaptureViewSnapshotTests.swift
- [ ] T093 Performance profiling and optimization for app launch time (<400ms)
- [ ] T094 Performance profiling for scroll animations (60fps target)
- [x] T095 [P] Add structured logging throughout services
- [x] T096 [P] Create Settings screen with API key configuration in Luno/Features/Settings/
- [x] T097 [P] Implement iCloud sync toggle in Settings (SyncService)
- [ ] T098 Run quickstart.md validation - verify all setup steps work
- [ ] T099 Final code cleanup and SwiftLint/SwiftFormat pass

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-8)**: All depend on Foundational phase completion
  - US1 (P1): Voice Capture - Can start immediately after Foundational
  - US2 (P2): AI Categorization - Depends on US1 (save flow integration)
  - US3 (P3): Text Input - Depends on US1 (extends CaptureView)
  - US4 (P4): Browse Notes - Can start after Foundational (parallel with US1-3)
  - US5 (P5): PARA Folders - Can start after Foundational (parallel with US1-4)
  - US6 (P6): Re-categorization - Depends on US4/US5 (note detail navigation)
- **Polish (Phase 9)**: Depends on all user stories being complete

### User Story Dependencies Graph

```
Foundational (Phase 2)
        │
        ├──────────────┬──────────────┬──────────────┐
        ▼              ▼              ▼              ▼
      US1 (P1)       US4 (P4)      US5 (P5)     (parallel)
   Voice Capture   Browse Notes  PARA Folders
        │              │              │
        ▼              └──────┬───────┘
      US2 (P2)                │
   AI Categorization          │
        │                     ▼
        ▼                   US6 (P6)
      US3 (P3)          Re-categorization
    Text Input
```

### Within Each User Story

1. Tests MUST be written and FAIL before implementation
2. Models/enums before services
3. Protocols before implementations
4. Services before ViewModels
5. ViewModels before Views
6. Core functionality before polish

### Parallel Opportunities

```bash
# Phase 1 - All setup tasks can run in parallel:
T003, T004, T005, T007, T008, T009, T010

# Phase 2 - Tests and independent models in parallel:
T011, T012, T013 (tests)
T014, T015, T017, T022, T023, T024, T025 (implementations)

# Phase 3 (US1) - Tests and independent components:
T026, T027, T028 (tests - parallel)
T030, T032, T033 (implementations - parallel)

# Phase 4 (US2) - Tests and models:
T040, T041, T042 (tests - parallel)
T045, T046, T047 (models/protocols - parallel)

# Phase 6 (US4) and Phase 7 (US5) can run entirely in parallel
```

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task: "Unit tests for SpeechService in LunoTests/Unit/Services/SpeechServiceTests.swift"
Task: "Unit tests for CaptureViewModel in LunoTests/Unit/ViewModels/CaptureViewModelTests.swift"
Task: "Snapshot tests for RecordButton states in LunoTests/Snapshots/RecordButtonSnapshotTests.swift"

# Launch independent components together:
Task: "Create SpeechServiceProtocol.swift in Luno/Core/Services/Protocols/"
Task: "Create RecordButton.swift animated component in Luno/Shared/Components/"
Task: "Create VoiceRecorderView.swift with waveform feedback in Luno/Features/Capture/"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 - Voice Note Capture
4. **STOP and VALIDATE**: Test voice capture independently
   - Can record voice
   - See real-time transcription
   - Review and edit
   - Save note locally
5. Deploy TestFlight build for early feedback

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. **US1 (Voice Capture)** → Test independently → **MVP Release!**
3. **US2 (AI Categorization)** → Test independently → Demo AI feature
4. **US3 (Text Input)** → Test independently → Full capture options
5. **US4 (Browse Notes)** → Test independently → Browsing enabled
6. **US5 (PARA Folders)** → Test independently → Organization complete
7. **US6 (Re-categorization)** → Test independently → Full PARA workflow
8. Polish → App Store submission

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: US1 (Voice) → US2 (AI) → US3 (Text)
   - Developer B: US4 (Browse) → US5 (Folders) → US6 (Re-cat)
3. Stories complete and integrate at checkpoints

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- **TDD is mandatory**: Tests must fail before implementation (Red-Green-Refactor)
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Constitution requires: 70% coverage new code, 80% coverage business logic
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
