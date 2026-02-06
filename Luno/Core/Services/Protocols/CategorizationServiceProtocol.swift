import Foundation

// MARK: - Categorization Service Protocol

// Protocol for AI-powered PARA categorization
// Constitution: Use protocols for testability

protocol CategorizationServiceProtocol: Sendable {
    /// Whether the service is available and ready
    var isAvailable: Bool { get async }

    /// Check availability and return reason if unavailable
    func checkAvailability() async -> CategorizationAvailability

    /// Categorizes note content into a PARA category
    func categorize(_ content: String) async throws -> CategorizationResult
}

// MARK: - Categorization Orchestrator Protocol

/// Protocol for the main orchestrator managing on-device + cloud fallback
protocol CategorizationOrchestratorProtocol: CategorizationServiceProtocol {
    /// Minimum confidence threshold for accepting on-device result
    var confidenceThreshold: Double { get }

    /// Categorizes with fallback strategy
    func categorizeWithFallback(_ content: String) async throws -> CategorizedNote
}
