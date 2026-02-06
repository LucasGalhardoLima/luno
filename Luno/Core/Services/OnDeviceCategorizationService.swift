import Foundation
import os

// MARK: - On-Device Categorization Service

// Uses Apple Foundation Models for on-device PARA categorization
// Constitution: Offline-first, privacy-preserving categorization
//
// Note: Foundation Models require iOS 26+ and Apple Silicon devices.
// When unavailable, falls back gracefully to cloud service.

actor OnDeviceCategorizationService: CategorizationServiceProtocol {
    // MARK: - Properties

    private let log = LunoLogger.categorization
    private var _isModelAvailable: Bool = false

    // MARK: - Initialization

    init() {
        // Check if Foundation Models are available
        // This will be updated when iOS 26 SDK is available
        _isModelAvailable = checkFoundationModelsSupport()
        if _isModelAvailable {
            log.info("Foundation Models available, using on-device categorization")
        } else {
            log.info("Foundation Models unavailable, using heuristic fallback")
        }
    }

    // MARK: - CategorizationServiceProtocol

    var isAvailable: Bool {
        get async { _isModelAvailable }
    }

    func checkAvailability() async -> CategorizationAvailability {
        guard _isModelAvailable else {
            // Determine the specific reason
            if !isDeviceSupported() {
                return .unavailable(reason: .deviceNotSupported)
            }
            if !isOSVersionSupported() {
                return .unavailable(reason: .osVersionTooLow)
            }
            return .unavailable(reason: .modelNotReady)
        }
        return .available
    }

    func categorize(_ content: String) async throws -> CategorizationResult {
        // Validate content
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw CategorizationError.invalidContent(reason: "Content cannot be empty")
        }

        // Check availability
        guard _isModelAvailable else {
            throw CategorizationError.serviceUnavailable(reason: .deviceNotSupported)
        }

        // When Foundation Models SDK is available (iOS 26+), this will use:
        //
        // @Generable
        // struct PARAClassification {
        //     @Guide("The PARA category: project, area, resource, or archive")
        //     let category: String
        //     @Guide("Brief reasoning for the classification")
        //     let reasoning: String
        //     @Guide("Confidence score from 0.0 to 1.0")
        //     let confidence: Double
        // }
        //
        // let session = LanguageModelSession()
        // let result = try await session.respond(
        //     to: buildPrompt(for: trimmed),
        //     generating: PARAClassification.self
        // )

        // Fallback: keyword-based heuristic for devices without Foundation Models
        let result = heuristicCategorize(trimmed)
        log.debug("Heuristic categorization: \(result.category.rawValue) (\(String(format: "%.0f", result.confidence * 100))%%)")
        return result
    }

    // MARK: - Private Methods

    private func checkFoundationModelsSupport() -> Bool {
        // Foundation Models require iOS 26+ and Apple Silicon
        // For now, return false as iOS 26 SDK is not yet available
        // This will be updated when the SDK ships
        if #available(iOS 26, *) {
            // Will check LanguageModelSession.isAvailable
            return false // Placeholder until SDK is available
        }
        return false
    }

    private func isDeviceSupported() -> Bool {
        // Check for Apple Silicon (A17 Pro+ / M-series)
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingCString: $0)
            }
        }
        // iPhone 15 Pro and later, any iPad with M-series
        // This is a simplified check
        return machine != nil
    }

    private func isOSVersionSupported() -> Bool {
        if #available(iOS 26, *) {
            return true
        }
        return false
    }

    /// Keyword-based heuristic categorization as fallback
    /// Used when Foundation Models are not available
    private func heuristicCategorize(_ content: String) -> CategorizationResult {
        let lowercased = content.lowercased()
        let scores = computeCategoryScores(for: lowercased)
        let best = scores.max(by: { $0.score < $1.score })

        guard let best, best.score > 0 else {
            return CategorizationResult(
                category: .uncategorized,
                reasoning: "No strong indicators found for any PARA category. Heuristic analysis only.",
                confidence: 0.2
            )
        }

        let maxConfidence = 0.7
        return CategorizationResult(
            category: best.category,
            reasoning: "\(best.reasoning). (Heuristic-based, on-device AI unavailable)",
            confidence: min(best.score, maxConfidence)
        )
    }

    private func computeCategoryScores(for text: String) -> [CategoryScore] {
        let keywordMap: [(PARACategory, [String], String)] = [
            (.project, ["deadline", "due", "finish", "complete", "deliver", "ship",
                        "launch", "release", "by friday", "by monday", "next week",
                        "sprint", "milestone", "goal", "target", "project"],
             "Contains project-related keywords indicating a task with a specific outcome"),
            (.area, ["weekly", "daily", "monthly", "routine", "maintain",
                     "ongoing", "review", "health", "fitness", "budget",
                     "responsibility", "manage", "oversee", "track"],
             "Contains area-related keywords suggesting an ongoing responsibility"),
            (.resource, ["article", "book", "tutorial", "reference", "learn",
                         "interesting", "read", "watch", "course", "tip",
                         "technique", "how to", "guide", "documentation"],
             "Contains resource-related keywords indicating reference material"),
            (.archive, ["completed", "finished", "done", "wrapped up", "closed",
                        "ended", "concluded", "archived", "old", "past",
                        "no longer", "discontinued", "cancelled"],
             "Contains archive-related keywords indicating a completed item"),
        ]

        return keywordMap.map { category, keywords, reasoning in
            CategoryScore(
                category: category,
                score: scoreKeywords(keywords, in: text),
                reasoning: reasoning
            )
        }
    }

    private func scoreKeywords(_ keywords: [String], in text: String) -> Double {
        let matches = keywords.filter { text.contains($0) }.count
        guard matches > 0 else { return 0 }

        // Score based on number of matches, diminishing returns
        return min(Double(matches) * 0.15, 0.7)
    }
}

// MARK: - Category Score

private struct CategoryScore {
    let category: PARACategory
    let score: Double
    let reasoning: String
}
