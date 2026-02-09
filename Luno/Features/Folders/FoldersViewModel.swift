import Foundation
import SwiftUI

// MARK: - Folders View Model

// ViewModel for PARA folder browsing with note counts
// Constitution: MVVM with clear separation of concerns

@MainActor
@Observable
final class FoldersViewModel {
    // MARK: - Properties

    private let log = LunoLogger.ui

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

    /// Fetch counts for all categories from a single query
    func fetchCounts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let allNotes = try await noteRepository.fetchNotes(category: nil)
            var counts: [PARACategory: Int] = [:]
            for category in PARACategory.allCases {
                counts[category] = allNotes.filter { $0.category == category }.count
            }
            categoryCounts = counts
            log.debug("Folder counts updated: \(counts.map { "\($0.key.rawValue)=\($0.value)" }.joined(separator: ", ")), total=\(allNotes.count)")
        } catch {
            log.error("Failed to fetch counts: \(error.localizedDescription)")
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
