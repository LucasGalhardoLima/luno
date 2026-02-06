# Feature Specification: Voice-First Notes with PARA Categorization

**Feature Branch**: `001-voice-notes-para`
**Created**: 2026-02-04
**Status**: Draft
**Input**: User description: "Build an iOS app that can help me take notes quickly using voice first but can have typing as the second option. After the note is taken, the app will use AI to categorize the note according to the PARA method. That categorization will be prompted for user confirmation. Focusing on a minimalist approach."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Voice Note Capture (Priority: P1)

As a user, I want to quickly capture a thought or idea using my voice so that I can record information without typing, especially when my hands are busy or I'm on the go.

**Why this priority**: Voice capture is the primary input method and core value proposition. Without fast voice capture, the app fails its fundamental purpose.

**Independent Test**: Can be fully tested by speaking a note and verifying it appears as text. Delivers immediate value as a voice-to-text notepad.

**Acceptance Scenarios**:

1. **Given** the app is open, **When** I tap the prominent record button and speak, **Then** my speech is transcribed to text in real-time with visible feedback
2. **Given** I am recording a note, **When** I pause speaking for 2 seconds or tap stop, **Then** the recording ends and I see my complete transcribed note
3. **Given** I have finished recording, **When** the transcription completes, **Then** I can review and edit the text before saving
4. **Given** I am in any screen, **When** I long-press the record button (or use a gesture), **Then** quick capture mode activates immediately without navigation

---

### User Story 2 - AI-Powered PARA Categorization (Priority: P2)

As a user, I want the app to automatically suggest which PARA category my note belongs to so that I spend less time organizing and more time capturing ideas.

**Why this priority**: AI categorization is the key differentiator that makes this app more than a basic voice recorder. It reduces friction in the organization workflow.

**Independent Test**: Can be tested by creating notes with different content types and verifying appropriate category suggestions appear. Delivers value by reducing manual organization effort.

**Acceptance Scenarios**:

1. **Given** I have captured a note about a deadline-driven task, **When** categorization runs, **Then** the AI suggests "Project" with a brief explanation why
2. **Given** I have captured a note about an ongoing responsibility (health, finances, relationships), **When** categorization runs, **Then** the AI suggests "Area" category
3. **Given** I have captured a note with reference information (article summary, how-to, facts), **When** categorization runs, **Then** the AI suggests "Resource" category
4. **Given** the AI suggests a category, **When** I view the suggestion, **Then** I see the recommended category, confidence indicator, and can accept, change, or defer the decision
5. **Given** the AI cannot confidently categorize a note, **When** displaying options, **Then** it shows "Uncategorized" as default with all PARA options available

---

### User Story 3 - Text Input as Alternative (Priority: P3)

As a user, I want to type notes when voice input isn't appropriate (quiet environments, private information) so that I always have a way to capture thoughts.

**Why this priority**: Essential fallback that ensures the app is usable in all situations, but secondary to the voice-first experience.

**Independent Test**: Can be tested by typing a note and saving it. Delivers basic note-taking value even without voice features.

**Acceptance Scenarios**:

1. **Given** I am on the capture screen, **When** I tap the text input area, **Then** the keyboard appears and I can type my note
2. **Given** I am typing a note, **When** I finish and tap save, **Then** the note proceeds to AI categorization just like voice notes
3. **Given** I started with voice input, **When** I want to add or correct text, **Then** I can seamlessly switch to typing without losing content

---

### User Story 4 - Browse All Notes (Priority: P4)

As a user, I want to see all my notes in one place as visually appealing floating cards so that I can quickly scan and find any note regardless of its category.

**Why this priority**: The Notes view provides a unified browsing experience that complements the organized Folders view, supporting different retrieval patterns.

**Independent Test**: Can be tested by creating multiple notes and verifying they all appear as floating cards in the Notes screen.

**Acceptance Scenarios**:

1. **Given** I have captured multiple notes, **When** I navigate to the Notes screen, **Then** I see all notes displayed as floating cards with subtle shadows and rounded corners
2. **Given** I am viewing the Notes screen, **When** I scroll through my notes, **Then** cards animate smoothly with gentle depth effects
3. **Given** I see a note card, **When** I look at it, **Then** I see a preview snippet of the content and a small category indicator
4. **Given** I am in the Notes screen, **When** I tap a note card, **Then** I see the full note content with options to edit or recategorize

---

### User Story 5 - Browse Notes by PARA Folders (Priority: P5)

As a user, I want to view my notes organized into PARA folders so that I can find information based on its purpose (active projects, areas of responsibility, reference material, or archived items).

**Why this priority**: The Folders view enables intentional, organized retrieval when users know what category they need.

**Independent Test**: Can be tested by creating notes in different categories and verifying they appear in the correct PARA folder.

**Acceptance Scenarios**:

1. **Given** I have notes in multiple PARA categories, **When** I navigate to the Folders screen, **Then** I see four PARA folders (Projects, Areas, Resources, Archive) each showing note count
2. **Given** I am viewing the Folders screen, **When** I tap a folder, **Then** I see all notes in that category displayed as floating cards
3. **Given** I want to move a note to Archive, **When** I complete or no longer need it, **Then** I can archive it with a simple action
4. **Given** I have archived notes, **When** I access the Archive folder, **Then** I can view or restore them

---

### User Story 6 - Quick Re-categorization (Priority: P6)

As a user, I want to easily change a note's category if the AI suggestion was wrong or my needs changed so that my organization stays accurate over time.

**Why this priority**: Correction capability is essential but used less frequently than capture and browse.

**Independent Test**: Can be tested by changing a note's category and verifying it moves to the new location.

**Acceptance Scenarios**:

1. **Given** I am viewing a note, **When** I tap the category indicator, **Then** I see all PARA categories and can select a different one
2. **Given** I change a note's category, **When** I confirm the change, **Then** the note immediately appears in the new category and updates in both Notes and Folders views
3. **Given** I am in the categorization confirmation flow, **When** I disagree with the AI suggestion, **Then** I can select the correct category before saving

---

### Edge Cases

- What happens when speech recognition fails or returns empty text? → Show error with retry option; do not save empty notes
- How does the system handle very long voice recordings? → Support recordings up to 5 minutes; show time remaining indicator
- What happens when AI categorization service is unavailable? → Save note as "Uncategorized" with option to categorize later
- How does the app handle notes that could fit multiple categories? → Show primary suggestion with alternative options visible
- What happens when the user cancels mid-recording? → Discard partial recording with confirmation if substantial content exists
- How are notes handled during poor network conditions? → Voice transcription works offline; AI categorization queues for when online

## Requirements *(mandatory)*

### Functional Requirements

**Voice Capture**
- **FR-001**: App MUST provide a single-tap method to start voice recording from the main screen
- **FR-002**: App MUST display real-time transcription feedback while recording
- **FR-003**: App MUST automatically detect end of speech (2-second pause) or allow manual stop
- **FR-004**: App MUST allow users to review and edit transcribed text before saving
- **FR-005**: Voice transcription MUST work without internet connectivity

**Text Input**
- **FR-006**: App MUST provide text input as an alternative to voice on the capture screen
- **FR-007**: App MUST allow seamless switching between voice and text input within the same note

**AI Categorization**
- **FR-008**: App MUST analyze note content and suggest one PARA category (Project, Area, Resource, Archive)
- **FR-009**: App MUST display AI category suggestion with brief reasoning before saving
- **FR-010**: App MUST allow users to accept, modify, or skip categorization
- **FR-011**: App MUST provide "Uncategorized" option when user wants to decide later
- **FR-012**: AI categorization MUST queue and retry when offline, applying when connectivity returns

**App Navigation & Structure**
- **FR-013**: App MUST have three main screens: Capture (home), Notes, and Folders
- **FR-014**: Capture screen MUST present a clean, blank-page interface inspired by a notebook, with voice and text input options
- **FR-015**: Notes screen MUST display all notes as floating cards with subtle shadows, rounded corners, and smooth scroll animations
- **FR-016**: Folders screen MUST display four PARA folders (Projects, Areas, Resources, Archive) each showing note count

**PARA Organization**
- **FR-017**: App MUST organize notes into four PARA categories: Projects, Areas, Resources, Archive
- **FR-018**: Users MUST be able to change a note's category at any time
- **FR-019**: Tapping a PARA folder MUST show notes in that category as floating cards (consistent with Notes screen style)

**Data & Persistence**
- **FR-020**: App MUST persist all notes locally on device
- **FR-021**: App MUST preserve note creation timestamp and last modified timestamp
- **FR-022**: App MUST support deleting notes with confirmation

### Key Entities

- **Note**: The core content unit; contains transcribed/typed text, creation date, last modified date, source type (voice/text), and assigned PARA category
- **PARA Category**: One of four organization buckets—Project (deadline-driven outcomes), Area (ongoing responsibilities), Resource (reference material), Archive (inactive items)
- **Categorization Suggestion**: AI-generated recommendation linking a note to a PARA category; includes confidence level and reasoning snippet

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can capture a voice note and see transcription in under 3 seconds from tapping record
- **SC-002**: 80% of AI category suggestions are accepted by users without modification
- **SC-003**: Users can capture, categorize, and save a note in under 30 seconds total
- **SC-004**: App launches to capture-ready state in under 2 seconds
- **SC-005**: Voice transcription accuracy exceeds 90% for clear speech in supported languages
- **SC-006**: Users can find any note by category within 3 taps from the home screen
- **SC-007**: App remains fully functional for capture and local browsing without internet connectivity

## Assumptions

- Voice transcription will use the device's native speech recognition capabilities
- AI categorization will use a cloud-based or on-device language model (implementation detail TBD)
- Initial release targets a single language (English) with potential for expansion
- Notes are stored locally only in v1; sync/backup is out of scope for this specification
- The PARA method definitions follow Tiago Forte's original framework
