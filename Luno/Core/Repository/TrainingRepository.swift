import Foundation
import os
import SwiftData

// MARK: - Training Repository Protocol

// Protocol for training example persistence
// Constitution: Use protocols for testability

protocol TrainingRepositoryProtocol: Sendable {
    /// Save a training example from cloud fallback
    func save(_ example: TrainingExample) async throws

    /// Fetch recent training examples
    func fetchExamples(limit: Int) async throws -> [TrainingExample]

    /// Fetch examples for a specific category
    func fetchExamples(for category: PARACategory) async throws -> [TrainingExample]

    /// Count total training examples
    func count() async throws -> Int
}

// MARK: - Training Repository

@ModelActor
actor TrainingRepository: TrainingRepositoryProtocol {
    private let log = LunoLogger.repository

    func save(_ example: TrainingExample) async throws {
        modelContext.insert(example)
        try modelContext.save()
        log.debug("Training example saved for category: \(example.categoryRaw)")
    }

    func fetchExamples(limit: Int) async throws -> [TrainingExample] {
        var descriptor = FetchDescriptor<TrainingExample>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }

    func fetchExamples(for category: PARACategory) async throws -> [TrainingExample] {
        let categoryRaw = category.rawValue
        let descriptor = FetchDescriptor<TrainingExample>(
            predicate: #Predicate<TrainingExample> { example in
                example.categoryRaw == categoryRaw
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func count() async throws -> Int {
        let descriptor = FetchDescriptor<TrainingExample>()
        return try modelContext.fetchCount(descriptor)
    }
}
