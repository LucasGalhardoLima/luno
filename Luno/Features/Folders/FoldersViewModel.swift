import Foundation
import SwiftUI

// MARK: - Folders View Model

// ViewModel for PARA folder browsing with note counts
// Constitution: MVVM with clear separation of concerns

@MainActor
@Observable
final class FoldersViewModel {
    // MARK: - Properties

    /// Note counts per category
    private var categoryCounts: [PARACategory: Int] = [:]

    /// Loading state
    var isLoading: Bool = false

    /// Error
    var error: AppError?

    /// Total notes across all categories
    var totalNoteCount: Int {
        categoryCounts.values.reduce(0, +)
    }

    // MARK: - Dependencies

    private let noteRepository: any NoteRepositoryProtocol

    // MARK: - Initialization

    init(noteRepository: any NoteRepositoryProtocol) {
        self.noteRepository = noteRepository
    }

    // MARK: - Methods

    /// Get note count for a specific category
    func noteCount(for category: PARACategory) -> Int {
        categoryCounts[category] ?? 0
    }

    /// Fetch counts for all categories
    func fetchCounts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            for category in PARACategory.allCases {
                let count = try await noteRepository.countNotes(category: category)
                categoryCounts[category] = count
            }
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    /// Fetch notes for a specific category
    func fetchNotes(for category: PARACategory) async -> [Note] {
        do {
            return try await noteRepository.fetchNotes(category: category)
        } catch {
            self.error = .unknown(error.localizedDescription)
            return []
        }
    }
}
