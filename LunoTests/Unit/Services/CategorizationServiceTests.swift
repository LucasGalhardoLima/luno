@testable import Luno
import XCTest

/// Unit tests for CategorizationService orchestrator
/// TDD: Tests for on-device + cloud fallback logic
final class CategorizationServiceTests: XCTestCase {
    // MARK: - Properties

    var sut: CategorizationService!
    var mockOnDevice: MockCategorizationService!
    var mockCloud: MockCategorizationService!
    var mockTrainingRepo: MockTrainingRepository!

    // MARK: - Setup

    override func setUp() async throws {
        try await super.setUp()
        mockOnDevice = MockCategorizationService(name: "onDevice")
        mockCloud = MockCategorizationService(name: "cloud")
        mockTrainingRepo = MockTrainingRepository()

        sut = CategorizationService(
            onDeviceService: mockOnDevice,
            cloudService: mockCloud,
            trainingRepository: mockTrainingRepo,
            config: CategorizationConfig(confidenceThreshold: 0.8)
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockOnDevice = nil
        mockCloud = nil
        mockTrainingRepo = nil
        try await super.tearDown()
    }

    // MARK: - Availability Tests

    func test_isAvailable_whenOnDeviceAvailable_returnsTrue() async {
        // Given
        mockOnDevice.mockIsAvailable = true

        // When
        let available = await sut.isAvailable

        // Then
        XCTAssertTrue(available)
    }

    func test_isAvailable_whenOnlyCloudAvailable_returnsTrue() async {
        // Given
        mockOnDevice.mockIsAvailable = false
        mockCloud.mockIsAvailable = true

        // When
        let available = await sut.isAvailable

        // Then
        XCTAssertTrue(available)
    }

    func test_isAvailable_whenNeitherAvailable_returnsFalse() async {
        // Given
        mockOnDevice.mockIsAvailable = false
        mockCloud.mockIsAvailable = false

        // When
        let available = await sut.isAvailable

        // Then
        XCTAssertFalse(available)
    }

    // MARK: - Fallback Logic Tests

    func test_categorizeWithFallback_highConfidenceOnDevice_usesOnDevice() async throws {
        // Given
        mockOnDevice.mockIsAvailable = true
        mockOnDevice.mockResult = CategorizationResult(
            category: .project,
            reasoning: "Contains deadline",
            confidence: 0.95
        )

        // When
        let categorized = try await sut.categorizeWithFallback("Finish by Friday")

        // Then
        XCTAssertEqual(categorized.result.category, .project)
        XCTAssertEqual(categorized.source, .onDevice)
        XCTAssertEqual(mockOnDevice.categorizeCallCount, 1)
        XCTAssertEqual(mockCloud.categorizeCallCount, 0)
    }

    func test_categorizeWithFallback_lowConfidenceOnDevice_fallsBackToCloud() async throws {
        // Given
        mockOnDevice.mockIsAvailable = true
        mockOnDevice.mockResult = CategorizationResult(
            category: .project,
            reasoning: "Maybe a project",
            confidence: 0.5 // Below 0.8 threshold
        )
        mockCloud.mockIsAvailable = true
        mockCloud.mockResult = CategorizationResult(
            category: .area,
            reasoning: "Ongoing responsibility",
            confidence: 0.9
        )

        // When
        let categorized = try await sut.categorizeWithFallback("Review weekly metrics")

        // Then
        XCTAssertEqual(categorized.result.category, .area)
        XCTAssertEqual(categorized.source, .cloud)
        XCTAssertEqual(mockOnDevice.categorizeCallCount, 1)
        XCTAssertEqual(mockCloud.categorizeCallCount, 1)
    }

    func test_categorizeWithFallback_onDeviceUnavailable_usesCloud() async throws {
        // Given
        mockOnDevice.mockIsAvailable = false
        mockCloud.mockIsAvailable = true
        mockCloud.mockResult = CategorizationResult(
            category: .resource,
            reasoning: "Reference material",
            confidence: 0.88
        )

        // When
        let categorized = try await sut.categorizeWithFallback("Great article about SwiftUI")

        // Then
        XCTAssertEqual(categorized.result.category, .resource)
        XCTAssertEqual(categorized.source, .cloud)
        XCTAssertEqual(mockOnDevice.categorizeCallCount, 0)
        XCTAssertEqual(mockCloud.categorizeCallCount, 1)
    }

    func test_categorizeWithFallback_onDeviceFails_fallsBackToCloud() async throws {
        // Given
        mockOnDevice.mockIsAvailable = true
        mockOnDevice.shouldThrow = CategorizationError.unknown(message: "Model error")
        mockCloud.mockIsAvailable = true
        mockCloud.mockResult = CategorizationResult(
            category: .project,
            reasoning: "Has deadline",
            confidence: 0.85
        )

        // When
        let categorized = try await sut.categorizeWithFallback("Finish report by Monday")

        // Then
        XCTAssertEqual(categorized.source, .cloud)
    }

    func test_categorizeWithFallback_bothFail_throwsError() async {
        // Given
        mockOnDevice.mockIsAvailable = false
        mockCloud.mockIsAvailable = false

        // When/Then
        do {
            _ = try await sut.categorizeWithFallback("Test content")
            XCTFail("Should throw error when both services are unavailable")
        } catch {
            // Expected
        }
    }

    // MARK: - Training Example Storage Tests

    func test_categorizeWithFallback_cloudFallback_storesTrainingExample() async throws {
        // Given
        mockOnDevice.mockIsAvailable = true
        mockOnDevice.mockResult = CategorizationResult(
            category: .project,
            reasoning: "Low confidence",
            confidence: 0.4
        )
        mockCloud.mockIsAvailable = true
        mockCloud.mockResult = CategorizationResult(
            category: .area,
            reasoning: "Ongoing task",
            confidence: 0.92
        )

        // When
        _ = try await sut.categorizeWithFallback("Weekly health review")

        // Then
        XCTAssertEqual(mockTrainingRepo.saveCallCount, 1)
        XCTAssertEqual(mockTrainingRepo.lastSavedExample?.category, .area)
    }

    func test_categorizeWithFallback_onDeviceSuccess_doesNotStoreTrainingExample() async throws {
        // Given
        mockOnDevice.mockIsAvailable = true
        mockOnDevice.mockResult = CategorizationResult(
            category: .project,
            reasoning: "Clear deadline",
            confidence: 0.95
        )

        // When
        _ = try await sut.categorizeWithFallback("Ship feature by Friday")

        // Then
        XCTAssertEqual(mockTrainingRepo.saveCallCount, 0)
    }

    // MARK: - Processing Time Tests

    func test_categorizeWithFallback_recordsProcessingTime() async throws {
        // Given
        mockOnDevice.mockIsAvailable = true
        mockOnDevice.mockResult = CategorizationResult(
            category: .project,
            reasoning: "Has deadline",
            confidence: 0.9
        )

        // When
        let categorized = try await sut.categorizeWithFallback("Test content")

        // Then
        XCTAssertGreaterThanOrEqual(categorized.processingTime, 0)
    }

    // MARK: - Confidence Threshold Tests

    func test_confidenceThreshold_isRespected() async throws {
        // Given - set threshold to 0.9
        let strictSut = CategorizationService(
            onDeviceService: mockOnDevice,
            cloudService: mockCloud,
            trainingRepository: mockTrainingRepo,
            config: CategorizationConfig(confidenceThreshold: 0.9)
        )

        mockOnDevice.mockIsAvailable = true
        mockOnDevice.mockResult = CategorizationResult(
            category: .project,
            reasoning: "Probably a project",
            confidence: 0.85 // Above 0.8 but below 0.9
        )
        mockCloud.mockIsAvailable = true
        mockCloud.mockResult = CategorizationResult(
            category: .project,
            reasoning: "Definitely a project",
            confidence: 0.95
        )

        // When
        let categorized = try await strictSut.categorizeWithFallback("Plan the launch")

        // Then - Should fallback because 0.85 < 0.9
        XCTAssertEqual(categorized.source, .cloud)
    }
}

// MARK: - Mock Categorization Service

final class MockCategorizationService: CategorizationServiceProtocol, @unchecked Sendable {
    let name: String
    var mockIsAvailable: Bool = true
    var mockResult: CategorizationResult?
    var shouldThrow: CategorizationError?
    var categorizeCallCount = 0

    init(name: String) {
        self.name = name
    }

    var isAvailable: Bool {
        get async { mockIsAvailable }
    }

    func checkAvailability() async -> CategorizationAvailability {
        mockIsAvailable ? .available : .unavailable(reason: .deviceNotSupported)
    }

    func categorize(_: String) async throws -> CategorizationResult {
        categorizeCallCount += 1

        if let error = shouldThrow {
            throw error
        }

        guard let result = mockResult else {
            throw CategorizationError.unknown(message: "No mock result configured")
        }

        return result
    }
}

// MARK: - Mock Training Repository

final class MockTrainingRepository: TrainingRepositoryProtocol, @unchecked Sendable {
    var examples: [TrainingExample] = []
    var lastSavedExample: TrainingExample?
    var saveCallCount = 0
    var fetchCallCount = 0

    func save(_ example: TrainingExample) async throws {
        saveCallCount += 1
        lastSavedExample = example
        examples.append(example)
    }

    func fetchExamples(limit: Int) async throws -> [TrainingExample] {
        fetchCallCount += 1
        return Array(examples.prefix(limit))
    }

    func fetchExamples(for category: PARACategory) async throws -> [TrainingExample] {
        examples.filter { $0.category == category }
    }

    func count() async throws -> Int {
        examples.count
    }
}
