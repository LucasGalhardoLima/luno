import Foundation
import SwiftData

// MARK: - Training Example

// Stored examples from cloud fallback for on-device model improvement
// Constitution: Learn from Claude API responses to improve on-device categorization

@Model
final class TrainingExample {
    /// Unique identifier
    var id: UUID

    /// The note content that was categorized
    var content: String

    /// The assigned PARA category
    var categoryRaw: String

    /// AI reasoning for the assignment
    var reasoning: String

    /// Confidence score from the cloud service
    var confidence: Double

    /// When this example was created
    var createdAt: Date

    /// Whether this example was confirmed by the user
    var userConfirmed: Bool

    /// The category (computed from raw)
    var category: PARACategory {
        get { PARACategory(rawValue: categoryRaw) ?? .uncategorized }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        content: String,
        category: PARACategory,
        reasoning: String,
        confidence: Double,
        userConfirmed: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.content = content
        categoryRaw = category.rawValue
        self.reasoning = reasoning
        self.confidence = confidence
        self.userConfirmed = userConfirmed
        self.createdAt = createdAt
    }
}
