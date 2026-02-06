# Data Model: Voice-First Notes with PARA Categorization

**Date**: 2026-02-04
**Feature**: 001-voice-notes-para

## Overview

This document defines the SwiftData models for the Luno notes app. All models are designed for CloudKit compatibility (optional iCloud sync).

## Entities

### Note

The core entity representing a captured note.

```swift
import SwiftData
import Foundation

@Model
final class Note {
    // MARK: - Identity
    var id: UUID = UUID()

    // MARK: - Content
    var content: String = ""

    @Attribute(.allowsCloudEncryption)
    var encryptedContent: String?  // For sensitive notes (future)

    // MARK: - Metadata
    var createdAt: Date = Date()
    var modifiedAt: Date = Date()
    var sourceType: NoteSourceType = .text

    // MARK: - Categorization
    var category: PARACategory = .uncategorized
    var categoryConfidence: Double = 0.0
    var categoryReasoning: String = ""
    var wasCloudCategorized: Bool = false  // Track if fallback was used

    // MARK: - State
    var isPinned: Bool = false

    // MARK: - Initializer
    init(
        content: String,
        sourceType: NoteSourceType = .text,
        category: PARACategory = .uncategorized
    ) {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.sourceType = sourceType
        self.category = category
        self.categoryConfidence = 0.0
        self.categoryReasoning = ""
        self.wasCloudCategorized = false
        self.isPinned = false
    }
}
```

### NoteSourceType

Enum tracking how the note was captured.

```swift
enum NoteSourceType: String, Codable {
    case voice  // Captured via voice recording
    case text   // Typed manually
}
```

### PARACategory

The PARA categorization enum, compatible with Foundation Models `@Generable`.

```swift
import FoundationModels

@Generable
enum PARACategory: String, Codable, CaseIterable {
    case project      // Active projects with deadlines
    case area         // Ongoing areas of responsibility
    case resource     // Reference materials
    case archive      // Completed/inactive items
    case uncategorized // Not yet categorized

    var displayName: String {
        switch self {
        case .project: return "Projects"
        case .area: return "Areas"
        case .resource: return "Resources"
        case .archive: return "Archive"
        case .uncategorized: return "Uncategorized"
        }
    }

    var description: String {
        switch self {
        case .project:
            return "Active endeavors with deadlines and clear outcomes"
        case .area:
            return "Ongoing responsibilities you want to maintain"
        case .resource:
            return "Reference materials and information for future use"
        case .archive:
            return "Completed projects and inactive items"
        case .uncategorized:
            return "Notes pending categorization"
        }
    }

    var iconName: String {
        switch self {
        case .project: return "folder.fill"
        case .area: return "rectangle.stack.fill"
        case .resource: return "book.closed.fill"
        case .archive: return "archivebox.fill"
        case .uncategorized: return "questionmark.folder.fill"
        }
    }

    // Exclude uncategorized from main PARA folders
    static var paraCategories: [PARACategory] {
        [.project, .area, .resource, .archive]
    }
}
```

### CategorizationResult

Structure for AI categorization responses (Foundation Models `@Generable`).

```swift
import FoundationModels

@Generable
struct CategorizationResult {
    @Guide(description: "The PARA category that best fits this note")
    let category: PARACategory

    @Guide(description: "Brief explanation of why this category was chosen, 1-2 sentences max")
    let reasoning: String

    @Guide(description: "Confidence level from 0.0 to 1.0", .range(0.0...1.0))
    let confidence: Double
}
```

### TrainingExample

Stores examples where cloud fallback was used, for future on-device improvement.

```swift
import SwiftData
import Foundation

@Model
final class TrainingExample {
    var id: UUID = UUID()
    var noteContent: String = ""
    var assignedCategory: PARACategory = .uncategorized
    var createdAt: Date = Date()

    // User feedback (optional future feature)
    var userConfirmed: Bool = false
    var userCorrectedCategory: PARACategory?

    init(noteContent: String, assignedCategory: PARACategory) {
        self.id = UUID()
        self.noteContent = noteContent
        self.assignedCategory = assignedCategory
        self.createdAt = Date()
        self.userConfirmed = false
    }
}
```

## Entity Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                         Note                                 │
├─────────────────────────────────────────────────────────────┤
│ id: UUID                                                     │
│ content: String                                              │
│ createdAt: Date                                              │
│ modifiedAt: Date                                             │
│ sourceType: NoteSourceType (voice | text)                    │
│ category: PARACategory                                       │
│ categoryConfidence: Double                                   │
│ categoryReasoning: String                                    │
│ wasCloudCategorized: Bool                                    │
│ isPinned: Bool                                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    TrainingExample                           │
├─────────────────────────────────────────────────────────────┤
│ id: UUID                                                     │
│ noteContent: String                                          │
│ assignedCategory: PARACategory                               │
│ createdAt: Date                                              │
│ userConfirmed: Bool                                          │
│ userCorrectedCategory: PARACategory?                         │
└─────────────────────────────────────────────────────────────┘
```

## Validation Rules

### Note
| Field | Validation |
|-------|------------|
| content | Non-empty string, max 50,000 characters |
| category | Valid PARACategory enum value |
| categoryConfidence | 0.0 to 1.0 range |
| createdAt | Must be <= modifiedAt |

### TrainingExample
| Field | Validation |
|-------|------------|
| noteContent | Non-empty string |
| assignedCategory | Valid PARACategory (not uncategorized) |

## State Transitions

### Note Categorization Flow

```
                    ┌─────────────┐
                    │   Created   │
                    │(uncategorized)│
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  AI Suggests │
                    │   Category   │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │  User    │ │  User    │ │  User    │
        │ Accepts  │ │ Changes  │ │ Defers   │
        └────┬─────┘ └────┬─────┘ └────┬─────┘
             │            │            │
             ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │Categorized│ │Categorized│ │Uncategorized│
        │(AI choice)│ │(user choice)│ │(pending)  │
        └──────────┘ └──────────┘ └──────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │ User can    │
                    │ re-categorize│
                    │ at any time │
                    └─────────────┘
```

## Indexes

For query performance:

```swift
// In Note model
@Attribute(.spotlight) var content: String  // Spotlight search

// Queries optimized for:
// 1. All notes sorted by modifiedAt (Notes view)
// 2. Notes filtered by category (Folders view)
// 3. Pinned notes (sorted first)
```

## CloudKit Considerations

### Schema Requirements (iCloud Sync)
- All properties have default values ✅
- No `@Attribute(.unique)` ✅
- Optional relationships only ✅ (none in current schema)

### Encryption
- `encryptedContent` uses `.allowsCloudEncryption` for end-to-end encryption
- Regular `content` is encrypted in transit but accessible for sync

### Sync Behavior
- Local-first: All changes persist locally immediately
- Background sync: CloudKit syncs when connectivity available
- Conflict resolution: Last-writer-wins (default)
