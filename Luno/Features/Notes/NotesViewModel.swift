import Foundation
import SwiftUI

// MARK: - Notes View Model

// ViewModel for browsing and managing notes
// Constitution: MVVM with clear separation of concerns

@MainActor
@Observable
final class NotesViewModel {
    // MARK: - Properties

    /// All loaded notes
    var notes: [Note] = []

    /// Loading state
    var isLoading: Bool = false

    /// Currently selected category filter
    var selectedCategory: PARACategory?

    /// Search text
    var searchText: String = ""

    /// Error
    var error: AppError?

    // MARK: - Dependencies

    private let noteRepository: any NoteRepositoryProtocol

    // MARK: - Initialization

    init(noteRepository: any NoteRepositoryProtocol) {
        self.noteRepository = noteRepository
    }

    // MARK: - Fetch

    func fetchNotes() async {
        isLoading = true
        defer { isLoading = false }

        do {
            notes = try await noteRepository.fetchNotes(category: selectedCategory)
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    // MARK: - Search

    func search(query: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                notes = try await noteRepository.fetchNotes(category: selectedCategory)
            } else {
                notes = try await noteRepository.search(query: query)
            }
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    // MARK: - Actions

    func deleteNote(_ note: Note) async {
        do {
            try await noteRepository.delete(note)
            notes.removeAll { $0.id == note.id }
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func togglePin(_ note: Note) async {
        note.isPinned.toggle()
        do {
            try await noteRepository.update(note)
        } catch {
            note.isPinned.toggle() // Revert
            self.error = .unknown(error.localizedDescription)
        }
    }
}
