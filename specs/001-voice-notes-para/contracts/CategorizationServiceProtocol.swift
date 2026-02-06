// MARK: - CategorizationServiceProtocol
// Contract for AI-powered PARA categorization

import Foundation

/// Protocol defining note categorization operations
/// Implementations:
/// - CategorizationService (orchestrator)
/// - OnDeviceCategorizationService (Foundation Models)
/// - ClaudeCategorizationService (API fallback)
protocol CategorizationServiceProtocol {

    // MARK: - Availability

    /// Whether the service is available and ready
    var isAvailable: Bool { get async }

    /// Check availability and return reason if unavailable
    func checkAvailability() async -> CategorizationAvailability

    // MARK: - Categorization

    /// Categorizes note content into a PARA category
    /// - Parameter content: The note text to categorize
    /// - Returns: Categorization result with category, reasoning, and confidence
    /// - Throws: CategorizationError if categorization fails
    func categorize(_ content: String) async throws -> CategorizationResult

    /// Categorizes multiple notes in batch
    /// - Parameter contents: Array of note texts
    /// - Returns: Array of results (same order as input)
    func categorizeBatch(_ contents: [String]) async throws -> [CategorizationResult]
}

/// Protocol for the main orchestrator that manages on-device + cloud fallback
protocol CategorizationOrchestratorProtocol: CategorizationServiceProtocol {

    /// Minimum confidence threshold for accepting on-device result
    var confidenceThreshold: Double { get set }

    /// Whether to store fallback examples for training
    var storeTrainingExamples: Bool { get set }

    /// Categorizes with fallback strategy
    /// - Parameter content: Note text
    /// - Returns: Result with metadata about which service was used
    func categorizeWithFallback(_ content: String) async throws -> CategorizedNote
}

// MARK: - Supporting Types

struct CategorizationResult: Equatable {
    let category: PARACategory
    let reasoning: String
    let confidence: Double

    static func == (lhs: CategorizationResult, rhs: CategorizationResult) -> Bool {
        lhs.category == rhs.category &&
        lhs.reasoning == rhs.reasoning &&
        abs(lhs.confidence - rhs.confidence) < 0.001
    }
}

struct CategorizedNote {
    let result: CategorizationResult
    let source: CategorizationSource
    let processingTime: TimeInterval
}

enum CategorizationSource {
    case onDevice       // Foundation Models
    case cloud          // Claude API
    case userOverride   // User manually selected
    case cached         // Previously categorized
}

enum CategorizationAvailability {
    case available
    case unavailable(reason: UnavailabilityReason)

    enum UnavailabilityReason {
        case deviceNotSupported     // Not iPhone 15 Pro+
        case osVersionTooLow        // Below iOS 26
        case appleIntelligenceOff   // User hasn't enabled
        case modelNotReady          // Still downloading
        case noApiKey               // Claude key not configured
        case noNetwork              // Offline + no on-device
    }
}

enum CategorizationError: Error, LocalizedError {
    case serviceUnavailable(reason: CategorizationAvailability.UnavailabilityReason)
    case invalidContent(reason: String)
    case networkError(underlying: Error)
    case apiError(statusCode: Int, message: String)
    case rateLimited(retryAfter: TimeInterval?)
    case timeout
    case unknown(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .serviceUnavailable(let reason):
            return "Categorization unavailable: \(reason)"
        case .invalidContent(let reason):
            return "Invalid content: \(reason)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .apiError(let code, let message):
            return "API error (\(code)): \(message)"
        case .rateLimited(let retryAfter):
            if let seconds = retryAfter {
                return "Rate limited. Retry in \(Int(seconds)) seconds"
            }
            return "Rate limited. Please try again later"
        case .timeout:
            return "Request timed out"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Configuration

struct CategorizationConfig {
    /// Minimum confidence to accept on-device result (default: 0.8)
    var confidenceThreshold: Double = 0.8

    /// Maximum time to wait for categorization (default: 10s)
    var timeout: TimeInterval = 10.0

    /// Whether to store fallback examples (default: true)
    var storeTrainingExamples: Bool = true

    /// Claude API key (empty = not configured)
    var claudeApiKey: String = ""

    /// Claude model to use
    var claudeModel: String = "claude-sonnet-4-20250514"
}
