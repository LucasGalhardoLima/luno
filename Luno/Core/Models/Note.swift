import Foundation
import SwiftData

// MARK: - Note Model

// Core data model for notes in Luno
// Constitution: Use SwiftData for type-safe persistence

@Model
final class Note: Hashable {
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Properties

    /// Unique identifier
    var id: UUID

    /// Note content (transcribed text or typed input)
    var content: String

    /// How the note was created
    var sourceType: NoteSourceType

    /// PARA category assignment
    var category: PARACategory

    /// AI confidence score for categorization (0.0 - 1.0)
    var categoryConfidence: Double

    /// AI reasoning for the category assignment
    var categoryReasoning: String

    /// Whether categorization was done by cloud AI (Claude) vs on-device
    var wasCloudCategorized: Bool

    /// Whether the note is pinned to top
    var isPinned: Bool

    /// Creation timestamp
    var createdAt: Date

    /// Last modification timestamp
    var modifiedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        content: String,
        sourceType: NoteSourceType = .text,
        category: PARACategory = .uncategorized,
        categoryConfidence: Double = 0.0,
        categoryReasoning: String = "",
        wasCloudCategorized: Bool = false,
        isPinned: Bool = false,
        createdAt: Date = Date(),
        modifiedAt: Date? = nil
    ) {
        self.id = id
        self.content = content
        self.sourceType = sourceType
        self.category = category
        self.categoryConfidence = categoryConfidence
        self.categoryReasoning = categoryReasoning
        self.wasCloudCategorized = wasCloudCategorized
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt ?? createdAt
    }
}
