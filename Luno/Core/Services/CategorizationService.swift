import Foundation
import os

// MARK: - Categorization Service

// Orchestrator for on-device + cloud PARA categorization
// Constitution: Try on-device first, fall back to Claude API at 80% threshold

actor CategorizationService: @preconcurrency CategorizationOrchestratorProtocol {
    // MARK: - Properties

    private let log = LunoLogger.categorization
    private let onDeviceService: any CategorizationServiceProtocol
    private let cloudService: any CategorizationServiceProtocol
    private let trainingRepository: any TrainingRepositoryProtocol
    private let config: CategorizationConfig

    var confidenceThreshold: Double {
        config.confidenceThreshold
    }

    // MARK: - Initialization

    init(
        onDeviceService: any CategorizationServiceProtocol,
        cloudService: any CategorizationServiceProtocol,
        trainingRepository: any TrainingRepositoryProtocol,
        config: CategorizationConfig = CategorizationConfig()
    ) {
        self.onDeviceService = onDeviceService
        self.cloudService = cloudService
        self.trainingRepository = trainingRepository
        self.config = config
    }

    // MARK: - CategorizationServiceProtocol

    var isAvailable: Bool {
        get async {
            let onDeviceAvailable = await onDeviceService.isAvailable
            let cloudAvailable = await cloudService.isAvailable
            return onDeviceAvailable || cloudAvailable
        }
    }

    func checkAvailability() async -> CategorizationAvailability {
        let onDeviceAvailable = await onDeviceService.isAvailable
        let cloudAvailable = await cloudService.isAvailable

        if onDeviceAvailable || cloudAvailable {
            return .available
        }

        // Return the most useful reason
        let onDeviceCheck = await onDeviceService.checkAvailability()
        if case let .unavailable(reason) = onDeviceCheck {
            return .unavailable(reason: reason)
        }

        return .unavailable(reason: .noNetwork)
    }

    func categorize(_ content: String) async throws -> CategorizationResult {
        let categorized = try await categorizeWithFallback(content)
        return categorized.result
    }

    // MARK: - CategorizationOrchestratorProtocol

    func categorizeWithFallback(_ content: String) async throws -> CategorizedNote {
        let startTime = Date()

        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            log.warning("Categorization requested with empty content")
            throw CategorizationError.invalidContent(reason: "Content cannot be empty")
        }

        log.info("Starting categorization for content (\(trimmed.count) chars)")

        if let result = try await tryOnDeviceCategorization(trimmed, startTime: startTime) {
            return result
        }

        if let result = try await tryCloudCategorization(trimmed, startTime: startTime) {
            return result
        }

        log.error("Both on-device and cloud categorization unavailable")
        throw CategorizationError.serviceUnavailable(reason: .noNetwork)
    }

    private func tryOnDeviceCategorization(_ content: String, startTime: Date) async throws -> CategorizedNote? {
        let onDeviceAvailable = await onDeviceService.isAvailable
        guard onDeviceAvailable else {
            log.debug("On-device categorization not available")
            return nil
        }

        let threshold = config.confidenceThreshold
        do {
            let result = try await onDeviceService.categorize(content)
            if result.confidence >= threshold {
                let elapsed = Date().timeIntervalSince(startTime)
                log.info("On-device categorization succeeded: \(result.category.rawValue) (\(String(format: "%.0f", result.confidence * 100))%%) in \(String(format: "%.2f", elapsed))s")
                return CategorizedNote(result: result, source: .onDevice, processingTime: elapsed)
            }
            log.info("On-device confidence \(String(format: "%.0f", result.confidence * 100))%% below threshold \(String(format: "%.0f", threshold * 100))%%, falling back to cloud")
        } catch {
            log.warning("On-device categorization failed: \(error.localizedDescription), falling back to cloud")
        }
        return nil
    }

    private func tryCloudCategorization(_ content: String, startTime: Date) async throws -> CategorizedNote? {
        let cloudAvailable = await cloudService.isAvailable
        guard cloudAvailable else { return nil }

        let shouldStoreTraining = config.storeTrainingExamples
        let result = try await cloudService.categorize(content)
        let elapsed = Date().timeIntervalSince(startTime)

        log.info("Cloud categorization succeeded: \(result.category.rawValue) (\(String(format: "%.0f", result.confidence * 100))%%) in \(String(format: "%.2f", elapsed))s")

        if shouldStoreTraining {
            await storeTrainingExample(content: content, result: result)
        }

        return CategorizedNote(result: result, source: .cloud, processingTime: elapsed)
    }

    // MARK: - Training Example Storage

    private func storeTrainingExample(content: String, result: CategorizationResult) async {
        let example = TrainingExample(
            content: content,
            category: result.category,
            reasoning: result.reasoning,
            confidence: result.confidence,
            userConfirmed: false
        )

        do {
            try await trainingRepository.save(example)
            log.debug("Training example stored for category: \(result.category.rawValue)")
        } catch {
            log.warning("Failed to store training example: \(error.localizedDescription)")
        }
    }
}
