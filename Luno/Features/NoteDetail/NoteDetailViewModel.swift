import Foundation
import SwiftUI

// MARK: - Note Detail View Model

// ViewModel for viewing, editing, and re-categorizing notes
// Constitution: MVVM with clear separation of concerns

@MainActor
@Observable
final class NoteDetailViewModel {
    // MARK: - Properties

    /// The note being viewed/edited
    var note: Note

    /// Content being edited (before save)
    var editedContent: String

    /// Whether in edit mode
    var isEditing: Bool = false

    /// Whether the note was deleted
    var isDeleted: Bool = false

    /// Error
    var error: AppError?

    // MARK: - Dependencies

    private let noteRepository: any NoteRepositoryProtocol

    // MARK: - Initialization

    init(note: Note, noteRepository: any NoteRepositoryProtocol) {
        self.note = note
        editedContent = note.content
        self.noteRepository = noteRepository
    }

    // MARK: - Editing

    func startEditing() {
        editedContent = note.content
        isEditing = true
    }

    func cancelEditing() {
        editedContent = note.content
        isEditing = false
    }

    func saveEdits() async {
        let trimmed = editedContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        note.content = trimmed
        do {
            try await noteRepository.update(note)
            isEditing = false
        } catch {
            self.error = .saveFailed(error.localizedDescription)
        }
    }

    // MARK: - Re-categorization

    func changeCategory(to category: PARACategory) async {
        note.category = category
        do {
            try await noteRepository.update(note)
        } catch {
            self.error = .saveFailed(error.localizedDescription)
        }
    }

    // MARK: - Pin

    func togglePin() async {
        note.isPinned.toggle()
        do {
            try await noteRepository.update(note)
        } catch {
            note.isPinned.toggle() // Revert
            self.error = .unknown(error.localizedDescription)
        }
    }

    // MARK: - Delete

    func deleteNote() async {
        do {
            try await noteRepository.delete(note)
            isDeleted = true
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }
}
