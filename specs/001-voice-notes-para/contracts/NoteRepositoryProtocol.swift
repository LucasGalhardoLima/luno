// MARK: - NoteRepositoryProtocol
// Contract for note persistence operations

import Foundation

/// Protocol defining note storage operations
/// Implementations: NoteRepository (SwiftData)
protocol NoteRepositoryProtocol {

    // MARK: - CRUD Operations

    /// Creates a new note and persists it
    /// - Parameter note: The note to create
    /// - Throws: RepositoryError if persistence fails
    func create(_ note: Note) async throws

    /// Fetches a note by its unique identifier
    /// - Parameter id: The note's UUID
    /// - Returns: The note if found, nil otherwise
    func fetch(by id: UUID) async -> Note?

    /// Updates an existing note
    /// - Parameter note: The note with updated values
    /// - Throws: RepositoryError if note doesn't exist or update fails
    func update(_ note: Note) async throws

    /// Deletes a note permanently
    /// - Parameter id: The note's UUID
    /// - Throws: RepositoryError if deletion fails
    func delete(by id: UUID) async throws

    // MARK: - Query Operations

    /// Fetches all notes, optionally filtered and sorted
    /// - Parameters:
    ///   - category: Filter by PARA category (nil for all)
    ///   - sortBy: Sort field (default: modifiedAt)
    ///   - ascending: Sort order (default: false, newest first)
    /// - Returns: Array of notes matching criteria
    func fetchAll(
        category: PARACategory?,
        sortBy: NoteSortField,
        ascending: Bool
    ) async -> [Note]

    /// Fetches notes count per category for folder badges
    /// - Returns: Dictionary of category to count
    func fetchCategoryCounts() async -> [PARACategory: Int]

    /// Fetches uncategorized notes pending AI categorization
    /// - Returns: Array of uncategorized notes
    func fetchUncategorized() async -> [Note]

    // MARK: - Batch Operations

    /// Updates category for multiple notes
    /// - Parameters:
    ///   - ids: Array of note UUIDs
    ///   - category: New category to assign
    /// - Throws: RepositoryError if any update fails
    func updateCategory(for ids: [UUID], to category: PARACategory) async throws
}

// MARK: - Supporting Types

enum NoteSortField {
    case createdAt
    case modifiedAt
    case content  // Alphabetical
}

enum RepositoryError: Error, LocalizedError {
    case notFound(UUID)
    case persistenceFailed(underlying: Error)
    case invalidData(reason: String)

    var errorDescription: String? {
        switch self {
        case .notFound(let id):
            return "Note not found: \(id)"
        case .persistenceFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .invalidData(let reason):
            return "Invalid data: \(reason)"
        }
    }
}
