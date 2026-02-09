@testable import Luno
import XCTest

/// Unit tests for FoldersViewModel
/// TDD: Tests for PARA folder browsing
@MainActor
final class FoldersViewModelTests: XCTestCase {
    // MARK: - Properties

    var sut: FoldersViewModel!
    var mockRepository: MockNoteRepository!

    // MARK: - Setup

    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockNoteRepository()
        sut = FoldersViewModel(noteRepository: mockRepository)
    }

    override func tearDown() async throws {
        sut = nil
        mockRepository = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func test_initialState_categoryCounts_areZero() {
        for category in PARACategory.paraCategories {
            XCTAssertEqual(sut.noteCount(for: category), 0)
        }
    }

    // MARK: - Fetch Counts Tests

    func test_fetchCounts_returnsCorrectCounts() async {
        // Given
        mockRepository.notes = [
            Note(content: "Project 1", category: .project),
            Note(content: "Project 2", category: .project),
            Note(content: "Area 1", category: .area),
            Note(content: "Resource 1", category: .resource)
        ]

        // When
        await sut.fetchCounts()

        // Then
        XCTAssertEqual(sut.noteCount(for: .project), 2)
        XCTAssertEqual(sut.noteCount(for: .area), 1)
        XCTAssertEqual(sut.noteCount(for: .resource), 1)
        XCTAssertEqual(sut.noteCount(for: .archive), 0)
    }

    func test_fetchCounts_includesUncategorized() async {
        // Given
        mockRepository.notes = [
            Note(content: "Uncategorized note", category: .uncategorized)
        ]

        // When
        await sut.fetchCounts()

        // Then
        XCTAssertEqual(sut.noteCount(for: .uncategorized), 1)
    }

    // MARK: - Fetch Notes for Category

    func test_fetchNotesForCategory_returnsFilteredNotes() async {
        // Given
        mockRepository.notes = [
            Note(content: "Project note", category: .project),
            Note(content: "Area note", category: .area)
        ]

        // When
        let notes = await sut.fetchNotes(for: .project)

        // Then
        XCTAssertEqual(notes.count, 1)
        XCTAssertEqual(notes.first?.category, .project)
    }

    // MARK: - Total Count Tests

    func test_totalNoteCount_returnsSum() async {
        // Given
        mockRepository.notes = [
            Note(content: "Note 1", category: .project),
            Note(content: "Note 2", category: .area),
            Note(content: "Note 3", category: .resource)
        ]

        // When
        await sut.fetchCounts()

        // Then
        XCTAssertEqual(sut.totalNoteCount, 3)
    }

    // MARK: - Folder Update After Save Tests

    func test_fetchCounts_updatesAfterNewNoteSaved() async {
        // Given - empty repository
        await sut.fetchCounts()
        XCTAssertEqual(sut.totalNoteCount, 0)

        // When - a new note is saved
        let note = Note(content: "New project note", category: .uncategorized)
        try? await mockRepository.save(note)
        await sut.fetchCounts()

        // Then - counts reflect the new note
        XCTAssertEqual(sut.totalNoteCount, 1)
        XCTAssertEqual(sut.noteCount(for: .uncategorized), 1)
    }

    func test_fetchCounts_updatesAfterCategoryChange() async {
        // Given - a note saved as uncategorized
        let note = Note(content: "Meeting notes for Q3 planning", category: .uncategorized)
        try? await mockRepository.save(note)
        await sut.fetchCounts()
        XCTAssertEqual(sut.noteCount(for: .uncategorized), 1)
        XCTAssertEqual(sut.noteCount(for: .project), 0)

        // When - category is updated (simulating categorization flow)
        try? await mockRepository.updateCategory(noteId: note.id, category: .project)
        await sut.fetchCounts()

        // Then - note moved from uncategorized to project
        XCTAssertEqual(sut.noteCount(for: .uncategorized), 0)
        XCTAssertEqual(sut.noteCount(for: .project), 1)
        XCTAssertEqual(sut.totalNoteCount, 1)
    }

    func test_fetchCounts_updatesAfterMultipleNotesWithDifferentCategories() async {
        // Given - save multiple notes with different categories
        let note1 = Note(content: "Project task", category: .uncategorized)
        let note2 = Note(content: "Weekly review", category: .uncategorized)
        let note3 = Note(content: "Useful article", category: .uncategorized)
        try? await mockRepository.save(note1)
        try? await mockRepository.save(note2)
        try? await mockRepository.save(note3)

        // When - each note gets categorized differently
        try? await mockRepository.updateCategory(noteId: note1.id, category: .project)
        try? await mockRepository.updateCategory(noteId: note2.id, category: .area)
        try? await mockRepository.updateCategory(noteId: note3.id, category: .resource)
        await sut.fetchCounts()

        // Then - each folder shows correct count
        XCTAssertEqual(sut.noteCount(for: .project), 1)
        XCTAssertEqual(sut.noteCount(for: .area), 1)
        XCTAssertEqual(sut.noteCount(for: .resource), 1)
        XCTAssertEqual(sut.noteCount(for: .uncategorized), 0)
        XCTAssertEqual(sut.totalNoteCount, 3)
    }
}
