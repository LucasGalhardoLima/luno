#if DEBUG
    import Foundation

    // MARK: - Preview Mock Repository

    // In-memory mock for SwiftUI previews
    // Only available in DEBUG builds

    final class MockNoteRepository: NoteRepositoryProtocol, @unchecked Sendable {
        var notes: [Note] = []
        var lastSavedNote: Note?
        var saveCallCount = 0
        var fetchCallCount = 0
        var deleteCallCount = 0
        var shouldThrowOnSave = false

        func fetchNotes(category: PARACategory?) async throws -> [Note] {
            fetchCallCount += 1
            if let category {
                return notes.filter { $0.category == category }
            }
            return notes
        }

        func fetchNote(by id: UUID) async throws -> Note? {
            notes.first { $0.id == id }
        }

        func save(_ note: Note) async throws {
            saveCallCount += 1
            if shouldThrowOnSave {
                throw NSError(domain: "MockError", code: 1)
            }
            lastSavedNote = note
            notes.append(note)
        }

        func update(_ note: Note) async throws {
            note.modifiedAt = Date()
        }

        func delete(_ note: Note) async throws {
            deleteCallCount += 1
            notes.removeAll { $0.id == note.id }
        }

        func search(query: String) async throws -> [Note] {
            notes.filter { $0.content.localizedCaseInsensitiveContains(query) }
        }

        func fetchNotes(sortedBy _: NoteSortOrder, ascending _: Bool) async throws -> [Note] {
            notes
        }

        func fetchPinnedNotes() async throws -> [Note] {
            notes.filter(\.isPinned)
        }

        func countNotes(category: PARACategory) async throws -> Int {
            notes.filter { $0.category == category }.count
        }
    }
#endif
