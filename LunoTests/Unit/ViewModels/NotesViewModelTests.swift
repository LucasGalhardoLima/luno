@testable import Luno
import XCTest

/// Unit tests for NotesViewModel
/// TDD: Tests for notes browsing and filtering
@MainActor
final class NotesViewModelTests: XCTestCase {
    // MARK: - Properties

    var sut: NotesViewModel!
    var mockRepository: MockNoteRepository!

    // MARK: - Setup

    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockNoteRepository()
        sut = NotesViewModel(noteRepository: mockRepository)
    }

    override func tearDown() async throws {
        sut = nil
        mockRepository = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func test_initialState_notesIsEmpty() {
        XCTAssertTrue(sut.notes.isEmpty)
    }

    func test_initialState_isLoadingIsFalse() {
        XCTAssertFalse(sut.isLoading)
    }

    func test_initialState_selectedFilterIsAll() {
        XCTAssertNil(sut.selectedCategory)
    }

    func test_initialState_searchTextIsEmpty() {
        XCTAssertTrue(sut.searchText.isEmpty)
    }

    // MARK: - Fetch Tests

    func test_fetchNotes_loadsAllNotes() async {
        // Given
        mockRepository.notes = [
            Note(content: "Note 1"),
            Note(content: "Note 2"),
            Note(content: "Note 3")
        ]

        // When
        await sut.fetchNotes()

        // Then
        XCTAssertEqual(sut.notes.count, 3)
    }

    func test_fetchNotes_setIsLoadingDuringFetch() async {
        // Given
        mockRepository.notes = [Note(content: "Test")]

        // When
        await sut.fetchNotes()

        // Then - After fetch completes, loading should be false
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Filter Tests

    func test_fetchNotes_withCategoryFilter_returnsFilteredNotes() async {
        // Given
        mockRepository.notes = [
            Note(content: "Project note", category: .project),
            Note(content: "Area note", category: .area),
            Note(content: "Another project", category: .project)
        ]
        sut.selectedCategory = .project

        // When
        await sut.fetchNotes()

        // Then
        XCTAssertEqual(sut.notes.count, 2)
        XCTAssertTrue(sut.notes.allSatisfy { $0.category == .project })
    }

    func test_clearFilter_showsAllNotes() async {
        // Given
        mockRepository.notes = [
            Note(content: "Project note", category: .project),
            Note(content: "Area note", category: .area)
        ]
        sut.selectedCategory = .project
        await sut.fetchNotes()
        XCTAssertEqual(sut.notes.count, 1)

        // When
        sut.selectedCategory = nil
        await sut.fetchNotes()

        // Then
        XCTAssertEqual(sut.notes.count, 2)
    }

    // MARK: - Search Tests

    func test_search_filtersNotesByContent() async {
        // Given
        mockRepository.notes = [
            Note(content: "Meeting notes for project"),
            Note(content: "Shopping list"),
            Note(content: "Team meeting agenda")
        ]

        // When
        await sut.search(query: "meeting")

        // Then
        XCTAssertEqual(sut.notes.count, 2)
    }

    func test_search_emptyQuery_showsAllNotes() async {
        // Given
        mockRepository.notes = [
            Note(content: "Note 1"),
            Note(content: "Note 2")
        ]

        // When
        await sut.search(query: "")

        // Then
        XCTAssertEqual(sut.notes.count, 2)
    }

    // MARK: - Delete Tests

    func test_deleteNote_removesNoteFromList() async {
        // Given
        let note = Note(content: "To delete")
        mockRepository.notes = [note]
        await sut.fetchNotes()
        XCTAssertEqual(sut.notes.count, 1)

        // When
        await sut.deleteNote(note)

        // Then
        XCTAssertEqual(mockRepository.deleteCallCount, 1)
    }

    // MARK: - Pin Tests

    func test_togglePin_changesNotePin() async {
        // Given
        let note = Note(content: "Test note", isPinned: false)
        mockRepository.notes = [note]

        // When
        await sut.togglePin(note)

        // Then
        XCTAssertTrue(note.isPinned)
    }
}
