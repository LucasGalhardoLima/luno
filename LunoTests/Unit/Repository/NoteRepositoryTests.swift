@testable import Luno
import SwiftData
import XCTest

/// Unit tests for NoteRepository
/// TDD: These tests define expected CRUD behavior
final class NoteRepositoryTests: XCTestCase {
    // MARK: - Properties

    var modelContainer: ModelContainer!
    var repository: NoteRepository!

    // MARK: - Setup

    override func setUp() async throws {
        try await super.setUp()

        let schema = Schema([Note.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        repository = NoteRepository(modelContainer: modelContainer)
    }

    override func tearDown() async throws {
        repository = nil
        modelContainer = nil
        try await super.tearDown()
    }

    // MARK: - Save Tests

    func test_save_persistsNote() async throws {
        // Given
        let note = Note(content: "Test note")

        // When
        try await repository.save(note)

        // Then
        let fetchedNotes = try await repository.fetchNotes(category: nil)
        XCTAssertEqual(fetchedNotes.count, 1)
        XCTAssertEqual(fetchedNotes.first?.content, "Test note")
    }

    func test_save_multipleNotes_persistsAll() async throws {
        // Given
        let note1 = Note(content: "Note 1")
        let note2 = Note(content: "Note 2")
        let note3 = Note(content: "Note 3")

        // When
        try await repository.save(note1)
        try await repository.save(note2)
        try await repository.save(note3)

        // Then
        let fetchedNotes = try await repository.fetchNotes(category: nil)
        XCTAssertEqual(fetchedNotes.count, 3)
    }

    // MARK: - Fetch Tests

    func test_fetchNotes_withNoCategory_returnsAllNotes() async throws {
        // Given
        let projectNote = Note(content: "Project note", category: .project)
        let areaNote = Note(content: "Area note", category: .area)
        try await repository.save(projectNote)
        try await repository.save(areaNote)

        // When
        let fetchedNotes = try await repository.fetchNotes(category: nil)

        // Then
        XCTAssertEqual(fetchedNotes.count, 2)
    }

    func test_fetchNotes_withCategory_returnsFilteredNotes() async throws {
        // Given
        let projectNote = Note(content: "Project note", category: .project)
        let areaNote = Note(content: "Area note", category: .area)
        try await repository.save(projectNote)
        try await repository.save(areaNote)

        // When
        let fetchedNotes = try await repository.fetchNotes(category: .project)

        // Then
        XCTAssertEqual(fetchedNotes.count, 1)
        XCTAssertEqual(fetchedNotes.first?.category, .project)
    }

    func test_fetchNote_byId_returnsCorrectNote() async throws {
        // Given
        let note = Note(content: "Specific note")
        try await repository.save(note)

        // When
        let fetchedNote = try await repository.fetchNote(by: note.id)

        // Then
        XCTAssertNotNil(fetchedNote)
        XCTAssertEqual(fetchedNote?.id, note.id)
        XCTAssertEqual(fetchedNote?.content, "Specific note")
    }

    func test_fetchNote_byId_withInvalidId_returnsNil() async throws {
        // Given
        let note = Note(content: "Some note")
        try await repository.save(note)

        // When
        let fetchedNote = try await repository.fetchNote(by: UUID())

        // Then
        XCTAssertNil(fetchedNote)
    }

    func test_fetchNotes_sortedByCreatedAt_ascending() async throws {
        // Given
        let oldNote = Note(content: "Old note", createdAt: Date().addingTimeInterval(-3600))
        let newNote = Note(content: "New note", createdAt: Date())
        try await repository.save(oldNote)
        try await repository.save(newNote)

        // When
        let fetchedNotes = try await repository.fetchNotes(sortedBy: .createdAt, ascending: true)

        // Then
        XCTAssertEqual(fetchedNotes.count, 2)
        XCTAssertEqual(fetchedNotes.first?.content, "Old note")
        XCTAssertEqual(fetchedNotes.last?.content, "New note")
    }

    func test_fetchNotes_sortedByCreatedAt_descending() async throws {
        // Given
        let oldNote = Note(content: "Old note", createdAt: Date().addingTimeInterval(-3600))
        let newNote = Note(content: "New note", createdAt: Date())
        try await repository.save(oldNote)
        try await repository.save(newNote)

        // When
        let fetchedNotes = try await repository.fetchNotes(sortedBy: .createdAt, ascending: false)

        // Then
        XCTAssertEqual(fetchedNotes.count, 2)
        XCTAssertEqual(fetchedNotes.first?.content, "New note")
        XCTAssertEqual(fetchedNotes.last?.content, "Old note")
    }

    func test_fetchPinnedNotes_returnsOnlyPinnedNotes() async throws {
        // Given
        let pinnedNote = Note(content: "Pinned note", isPinned: true)
        let unpinnedNote = Note(content: "Unpinned note", isPinned: false)
        try await repository.save(pinnedNote)
        try await repository.save(unpinnedNote)

        // When
        let fetchedNotes = try await repository.fetchPinnedNotes()

        // Then
        XCTAssertEqual(fetchedNotes.count, 1)
        XCTAssertTrue(fetchedNotes.first?.isPinned ?? false)
    }

    // MARK: - Update Tests

    func test_update_modifiesNoteContent() async throws {
        // Given
        let note = Note(content: "Original content")
        try await repository.save(note)

        // When
        note.content = "Updated content"
        try await repository.update(note)

        // Then
        let fetchedNote = try await repository.fetchNote(by: note.id)
        XCTAssertEqual(fetchedNote?.content, "Updated content")
    }

    func test_update_modifiesCategory() async throws {
        // Given
        let note = Note(content: "Test note", category: .uncategorized)
        try await repository.save(note)

        // When
        note.category = .project
        try await repository.update(note)

        // Then
        let fetchedNote = try await repository.fetchNote(by: note.id)
        XCTAssertEqual(fetchedNote?.category, .project)
    }

    func test_update_updatesModifiedAt() async throws {
        // Given
        let note = Note(content: "Test note")
        let originalModifiedAt = note.modifiedAt
        try await repository.save(note)

        // Wait a moment to ensure time difference
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second

        // When
        note.content = "Updated content"
        try await repository.update(note)

        // Then
        let fetchedNote = try await repository.fetchNote(by: note.id)
        XCTAssertNotNil(fetchedNote)
        XCTAssertGreaterThan(try XCTUnwrap(fetchedNote?.modifiedAt), originalModifiedAt)
    }

    // MARK: - Delete Tests

    func test_delete_removesNote() async throws {
        // Given
        let note = Note(content: "To be deleted")
        try await repository.save(note)

        // When
        try await repository.delete(note)

        // Then
        let fetchedNotes = try await repository.fetchNotes(category: nil)
        XCTAssertEqual(fetchedNotes.count, 0)
    }

    func test_delete_removesOnlySpecifiedNote() async throws {
        // Given
        let noteToDelete = Note(content: "Delete me")
        let noteToKeep = Note(content: "Keep me")
        try await repository.save(noteToDelete)
        try await repository.save(noteToKeep)

        // When
        try await repository.delete(noteToDelete)

        // Then
        let fetchedNotes = try await repository.fetchNotes(category: nil)
        XCTAssertEqual(fetchedNotes.count, 1)
        XCTAssertEqual(fetchedNotes.first?.content, "Keep me")
    }

    // MARK: - Search Tests

    func test_search_findsMatchingNotes() async throws {
        // Given
        let matchingNote = Note(content: "Meeting notes for project")
        let nonMatchingNote = Note(content: "Shopping list")
        try await repository.save(matchingNote)
        try await repository.save(nonMatchingNote)

        // When
        let results = try await repository.search(query: "meeting")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.content, "Meeting notes for project")
    }

    func test_search_isCaseInsensitive() async throws {
        // Given
        let note = Note(content: "Important MEETING")
        try await repository.save(note)

        // When
        let results = try await repository.search(query: "meeting")

        // Then
        XCTAssertEqual(results.count, 1)
    }

    func test_search_withNoMatches_returnsEmptyArray() async throws {
        // Given
        let note = Note(content: "Hello world")
        try await repository.save(note)

        // When
        let results = try await repository.search(query: "xyz123")

        // Then
        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - Count Tests

    func test_countNotes_returnsCorrectCount() async throws {
        // Given
        let projectNote1 = Note(content: "Project 1", category: .project)
        let projectNote2 = Note(content: "Project 2", category: .project)
        let areaNote = Note(content: "Area note", category: .area)
        try await repository.save(projectNote1)
        try await repository.save(projectNote2)
        try await repository.save(areaNote)

        // When
        let projectCount = try await repository.countNotes(category: .project)
        let areaCount = try await repository.countNotes(category: .area)
        let resourceCount = try await repository.countNotes(category: .resource)

        // Then
        XCTAssertEqual(projectCount, 2)
        XCTAssertEqual(areaCount, 1)
        XCTAssertEqual(resourceCount, 0)
    }
}
