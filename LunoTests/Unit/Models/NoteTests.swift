// swiftlint:disable single_test_class
@testable import Luno
import SwiftData
import XCTest

/// Unit tests for Note model
/// TDD: These tests must fail before implementation
final class NoteTests: XCTestCase {
    // MARK: - Initialization

    func test_init_withContent_setsDefaultValues() {
        // Given
        let content = "Test note content"

        // When
        let note = Note(content: content)

        // Then
        XCTAssertFalse(note.id.uuidString.isEmpty)
        XCTAssertEqual(note.content, content)
        XCTAssertEqual(note.sourceType, .text)
        XCTAssertEqual(note.category, .uncategorized)
        XCTAssertEqual(note.categoryConfidence, 0.0)
        XCTAssertEqual(note.categoryReasoning, "")
        XCTAssertFalse(note.wasCloudCategorized)
        XCTAssertFalse(note.isPinned)
    }

    func test_init_withVoiceSourceType() {
        // Given/When
        let note = Note(content: "Voice note", sourceType: .voice)

        // Then
        XCTAssertEqual(note.sourceType, .voice)
    }

    func test_init_withCategory() {
        // Given/When
        let note = Note(content: "Project note", category: .project)

        // Then
        XCTAssertEqual(note.category, .project)
    }

    func test_init_setsCreatedAtToNow() {
        // Given
        let beforeCreate = Date()

        // When
        let note = Note(content: "Test")
        let afterCreate = Date()

        // Then
        XCTAssertGreaterThanOrEqual(note.createdAt, beforeCreate)
        XCTAssertLessThanOrEqual(note.createdAt, afterCreate)
    }

    func test_init_setsModifiedAtEqualToCreatedAt() {
        // Given/When
        let note = Note(content: "Test")

        // Then
        XCTAssertEqual(note.createdAt, note.modifiedAt)
    }

    // MARK: - UUID Uniqueness

    func test_multipleNotes_haveUniqueIds() {
        // Given/When
        let note1 = Note(content: "Note 1")
        let note2 = Note(content: "Note 2")
        let note3 = Note(content: "Note 3")

        // Then
        XCTAssertNotEqual(note1.id, note2.id)
        XCTAssertNotEqual(note2.id, note3.id)
        XCTAssertNotEqual(note1.id, note3.id)
    }

    // MARK: - Content Validation

    func test_content_canBeEmpty() {
        // Given/When
        let note = Note(content: "")

        // Then - Empty content is allowed (validation happens at save)
        XCTAssertEqual(note.content, "")
    }

    func test_content_preservesWhitespace() {
        // Given
        let contentWithWhitespace = "  Line 1\n\nLine 2  "

        // When
        let note = Note(content: contentWithWhitespace)

        // Then
        XCTAssertEqual(note.content, contentWithWhitespace)
    }

    func test_content_preservesUnicode() {
        // Given
        let unicodeContent = "Hello 👋 World 🌍 日本語"

        // When
        let note = Note(content: unicodeContent)

        // Then
        XCTAssertEqual(note.content, unicodeContent)
    }

    // MARK: - Category Properties

    func test_categoryConfidence_defaultsToZero() {
        let note = Note(content: "Test")
        XCTAssertEqual(note.categoryConfidence, 0.0)
    }

    func test_categoryConfidence_canBeSetToValidRange() {
        // Given
        let note = Note(content: "Test")

        // When
        note.categoryConfidence = 0.85

        // Then
        XCTAssertEqual(note.categoryConfidence, 0.85, accuracy: 0.001)
    }

    func test_categoryReasoning_defaultsToEmpty() {
        let note = Note(content: "Test")
        XCTAssertEqual(note.categoryReasoning, "")
    }

    func test_categoryReasoning_canBeSet() {
        // Given
        let note = Note(content: "Test")
        let reasoning = "This note contains a deadline, indicating a project."

        // When
        note.categoryReasoning = reasoning

        // Then
        XCTAssertEqual(note.categoryReasoning, reasoning)
    }

    // MARK: - Cloud Categorization Tracking

    func test_wasCloudCategorized_defaultsToFalse() {
        let note = Note(content: "Test")
        XCTAssertFalse(note.wasCloudCategorized)
    }

    func test_wasCloudCategorized_canBeSetToTrue() {
        // Given
        let note = Note(content: "Test")

        // When
        note.wasCloudCategorized = true

        // Then
        XCTAssertTrue(note.wasCloudCategorized)
    }

    // MARK: - Pinned State

    func test_isPinned_defaultsToFalse() {
        let note = Note(content: "Test")
        XCTAssertFalse(note.isPinned)
    }

    func test_isPinned_canBeToggled() {
        // Given
        let note = Note(content: "Test")

        // When
        note.isPinned = true

        // Then
        XCTAssertTrue(note.isPinned)

        // When
        note.isPinned = false

        // Then
        XCTAssertFalse(note.isPinned)
    }

    // MARK: - Source Type

    func test_sourceType_defaultsToText() {
        let note = Note(content: "Test")
        XCTAssertEqual(note.sourceType, .text)
    }

    func test_sourceType_voice_canBeSet() {
        let note = Note(content: "Test", sourceType: .voice)
        XCTAssertEqual(note.sourceType, .voice)
    }
}

// MARK: - NoteSourceType Tests

final class NoteSourceTypeTests: XCTestCase {
    func test_voice_rawValue() {
        XCTAssertEqual(NoteSourceType.voice.rawValue, "voice")
    }

    func test_text_rawValue() {
        XCTAssertEqual(NoteSourceType.text.rawValue, "text")
    }

    func test_allCases_containsBothTypes() {
        XCTAssertTrue(NoteSourceType.allCases.contains(.voice))
        XCTAssertTrue(NoteSourceType.allCases.contains(.text))
        XCTAssertEqual(NoteSourceType.allCases.count, 2)
    }

    func test_codable_roundTrip() throws {
        for sourceType in NoteSourceType.allCases {
            let encoded = try JSONEncoder().encode(sourceType)
            let decoded = try JSONDecoder().decode(NoteSourceType.self, from: encoded)
            XCTAssertEqual(sourceType, decoded)
        }
    }
}
