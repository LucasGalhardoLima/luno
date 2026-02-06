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
}
