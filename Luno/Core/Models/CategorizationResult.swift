import Foundation

// MARK: - Categorization Result

// Result from AI-powered PARA categorization
// Constitution: Structured AI output with confidence tracking

struct CategorizationResult: Equatable, Sendable {
    /// The suggested PARA category
    let category: PARACategory

    /// AI reasoning for the category choice
    let reasoning: String

    /// Confidence score (0.0 - 1.0)
    let confidence: Double

    static func == (lhs: CategorizationResult, rhs: CategorizationResult) -> Bool {
        lhs.category == rhs.category &&
            lhs.reasoning == rhs.reasoning &&
            abs(lhs.confidence - rhs.confidence) < 0.001
    }
}

// MARK: - Categorized Note

/// Extended result including metadata about which service was used
struct CategorizedNote: Sendable {
    let result: CategorizationResult
    let source: CategorizationSource
    let processingTime: TimeInterval
}

// MARK: - Categorization Source

enum CategorizationSource: String, Sendable {
    /// On-device Foundation Models
    case onDevice = "on_device"
    /// Claude API fallback
    case cloud
    /// User manually selected
    case userOverride = "user_override"
    /// Previously categorized
    case cached
}

// MARK: - Categorization Availability

enum CategorizationAvailability: Sendable {
    case available
    case unavailable(reason: UnavailabilityReason)

    enum UnavailabilityReason: String, Sendable {
        /// Device doesn't support Foundation Models
        case deviceNotSupported
        /// iOS version too low for Foundation Models
        case osVersionTooLow
        /// Apple Intelligence not enabled
        case appleIntelligenceOff
        /// Model still downloading
        case modelNotReady
        /// Claude API key not configured
        case noApiKey
        /// Offline with no on-device fallback
        case noNetwork
    }
}

// MARK: - Categorization Error

enum CategorizationError: Error, LocalizedError, Sendable {
    case serviceUnavailable(reason: CategorizationAvailability.UnavailabilityReason)
    case invalidContent(reason: String)
    case networkError(message: String)
    case apiError(statusCode: Int, message: String)
    case rateLimited(retryAfter: TimeInterval?)
    case timeout
    case unknown(message: String)

    var errorDescription: String? {
        switch self {
        case let .serviceUnavailable(reason):
            return "Categorization unavailable: \(reason.rawValue)"
        case let .invalidContent(reason):
            return "Invalid content: \(reason)"
        case let .networkError(message):
            return "Network error: \(message)"
        case let .apiError(code, message):
            return "API error (\(code)): \(message)"
        case let .rateLimited(retryAfter):
            if let seconds = retryAfter {
                return "Rate limited. Retry in \(Int(seconds)) seconds."
            }
            return "Rate limited. Please try again later."
        case .timeout:
            return "Request timed out."
        case let .unknown(message):
            return "Unknown error: \(message)"
        }
    }
}

// MARK: - Categorization Config

struct CategorizationConfig: Sendable {
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
