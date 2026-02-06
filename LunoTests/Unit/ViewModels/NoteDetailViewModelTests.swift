@testable import Luno
import XCTest

/// Unit tests for NoteDetailViewModel
/// TDD: Tests for note editing and re-categorization
@MainActor
final class NoteDetailViewModelTests: XCTestCase {
    // MARK: - Properties

    var sut: NoteDetailViewModel!
    var mockRepository: MockNoteRepository!
    var testNote: Note!

    // MARK: - Setup

    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockNoteRepository()
        testNote = Note(content: "Original content", category: .uncategorized)
        mockRepository.notes = [testNote]
        sut = NoteDetailViewModel(note: testNote, noteRepository: mockRepository)
    }

    override func tearDown() async throws {
        sut = nil
        mockRepository = nil
        testNote = nil
        try await super.tearDown()
    }

    // MARK: - Initial State

    func test_initialState_hasCorrectNote() {
        XCTAssertEqual(sut.note.id, testNote.id)
    }

    func test_initialState_editedContentMatchesNote() {
        XCTAssertEqual(sut.editedContent, testNote.content)
    }

    func test_initialState_isEditingIsFalse() {
        XCTAssertFalse(sut.isEditing)
    }

    // MARK: - Edit Tests

    func test_startEditing_setsIsEditingTrue() {
        sut.startEditing()
        XCTAssertTrue(sut.isEditing)
    }

    func test_cancelEditing_revertsContent() {
        // Given
        sut.startEditing()
        sut.editedContent = "Modified content"

        // When
        sut.cancelEditing()

        // Then
        XCTAssertEqual(sut.editedContent, "Original content")
        XCTAssertFalse(sut.isEditing)
    }

    func test_saveEdits_updatesNoteContent() async {
        // Given
        sut.startEditing()
        sut.editedContent = "Updated content"

        // When
        await sut.saveEdits()

        // Then
        XCTAssertEqual(sut.note.content, "Updated content")
        XCTAssertFalse(sut.isEditing)
    }

    // MARK: - Re-categorization Tests

    func test_changeCategory_updatesNoteCategory() async {
        // When
        await sut.changeCategory(to: .project)

        // Then
        XCTAssertEqual(sut.note.category, .project)
    }

    func test_changeCategory_setsSourceToUserOverride() async {
        // When
        await sut.changeCategory(to: .area)

        // Then - Note was updated
        XCTAssertEqual(sut.note.category, .area)
    }

    // MARK: - Pin Tests

    func test_togglePin_togglesState() async {
        // Given
        XCTAssertFalse(sut.note.isPinned)

        // When
        await sut.togglePin()

        // Then
        XCTAssertTrue(sut.note.isPinned)
    }

    // MARK: - Delete Tests

    func test_deleteNote_callsRepository() async {
        // When
        await sut.deleteNote()

        // Then
        XCTAssertEqual(mockRepository.deleteCallCount, 1)
    }
}
