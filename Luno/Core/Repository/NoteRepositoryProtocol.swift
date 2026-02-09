import Foundation

// MARK: - Note Repository Protocol

// Protocol defining note persistence operations
// Constitution: Use protocols for testability and loose coupling

protocol NoteRepositoryProtocol: Sendable {
    /// Fetch all notes, optionally filtered by category
    func fetchNotes(category: PARACategory?) async throws -> [Note]

    /// Fetch a single note by ID
    func fetchNote(by id: UUID) async throws -> Note?

    /// Save a new note
    func save(_ note: Note) async throws

    /// Update an existing note
    func update(_ note: Note) async throws

    /// Update a note's category by ID (actor-safe for SwiftData)
    func updateCategory(noteId: UUID, category: PARACategory) async throws

    /// Delete a note
    func delete(_ note: Note) async throws

    /// Search notes by content
    func search(query: String) async throws -> [Note]

    /// Fetch notes sorted by date
    func fetchNotes(sortedBy: NoteSortOrder, ascending: Bool) async throws -> [Note]

    /// Fetch pinned notes
    func fetchPinnedNotes() async throws -> [Note]

    /// Count notes by category
    func countNotes(category: PARACategory) async throws -> Int
}

// MARK: - Note Sort Order

enum NoteSortOrder: String, Sendable {
    case createdAt
    case modifiedAt
    case content
}
