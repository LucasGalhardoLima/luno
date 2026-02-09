import Foundation
import os
import SwiftData

// MARK: - Note Repository

// SwiftData implementation of note persistence
// Constitution: Offline-first with local storage

@ModelActor
actor NoteRepository: NoteRepositoryProtocol {
    private let log = LunoLogger.repository

    // MARK: - Fetch Operations

    func fetchNotes(category: PARACategory?) async throws -> [Note] {
        var descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )

        if let category {
            descriptor.predicate = #Predicate<Note> { note in
                note.category == category
            }
        }

        return try modelContext.fetch(descriptor)
    }

    func fetchNote(by id: UUID) async throws -> Note? {
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate<Note> { note in
                note.id == id
            }
        )
        return try modelContext.fetch(descriptor).first
    }

    func fetchNotes(sortedBy: NoteSortOrder, ascending: Bool) async throws -> [Note] {
        let descriptor = switch sortedBy {
        case .createdAt:
            FetchDescriptor<Note>(
                sortBy: [SortDescriptor(\.createdAt, order: ascending ? .forward : .reverse)]
            )
        case .modifiedAt:
            FetchDescriptor<Note>(
                sortBy: [SortDescriptor(\.modifiedAt, order: ascending ? .forward : .reverse)]
            )
        case .content:
            FetchDescriptor<Note>(
                sortBy: [SortDescriptor(\.content, order: ascending ? .forward : .reverse)]
            )
        }

        return try modelContext.fetch(descriptor)
    }

    func fetchPinnedNotes() async throws -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate<Note> { note in
                note.isPinned == true
            },
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Search

    func search(query: String) async throws -> [Note] {
        let lowercasedQuery = query.lowercased()
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate<Note> { note in
                note.content.localizedStandardContains(lowercasedQuery)
            },
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    // MARK: - CRUD Operations

    func save(_ note: Note) async throws {
        modelContext.insert(note)
        try modelContext.save()
        log.debug("Note saved: \(note.id)")
    }

    func update(_ note: Note) async throws {
        note.modifiedAt = Date()
        try modelContext.save()
        log.debug("Note updated: \(note.id)")
    }

    func updateCategory(noteId: UUID, category: PARACategory) async throws {
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate<Note> { note in note.id == noteId }
        )
        guard let note = try modelContext.fetch(descriptor).first else { return }
        note.category = category
        note.modifiedAt = Date()
        try modelContext.save()
        log.debug("Note category updated to \(category.rawValue): \(noteId)")
    }

    func delete(_ note: Note) async throws {
        let id = note.id
        modelContext.delete(note)
        try modelContext.save()
        log.debug("Note deleted: \(id)")
    }

    // MARK: - Count

    func countNotes(category: PARACategory) async throws -> Int {
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate<Note> { note in
                note.category == category
            }
        )
        return try modelContext.fetchCount(descriptor)
    }
}
