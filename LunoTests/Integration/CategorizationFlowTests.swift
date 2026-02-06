@testable import Luno
import XCTest

/// Integration tests for categorization flow (T043)
/// Tests the full categorization pipeline: on-device → cloud fallback → training storage
final class CategorizationFlowTests: XCTestCase {
    // MARK: - Properties

    var mockOnDevice: MockCategorizationService!
    var mockCloud: MockCategorizationService!
    var mockTrainingRepo: MockTrainingRepository!

    // MARK: - Setup

    override func setUp() async throws {
        try await super.setUp()
        mockOnDevice = MockCategorizationService(name: "onDevice")
        mockCloud = MockCategorizationService(name: "cloud")
        mockTrainingRepo = MockTrainingRepository()
    }

    override func tearDown() async throws {
        mockOnDevice = nil
        mockCloud = nil
        mockTrainingRepo = nil
        try await super.tearDown()
    }

    // MARK: - Full Flow: On-Device Success

    func test_fullFlow_onDeviceHighConfidence_noCloudCall() async throws {
        // Given: On-device returns high confidence
        mockOnDevice.mockIsAvailable = true
        mockOnDevice.mockResult = CategorizationResult(
            category: .project,
            reasoning: "Contains deadline keywords",
            confidence: 0.92
        )
        mockCloud.mockIsAvailable = true

        let sut = CategorizationService(
            onDeviceService: mockOnDevice,
            cloudService: mockCloud,
            trainingRepository: mockTrainingRepo,
            config: CategorizationConfig(confidenceThreshold: 0.8)
        )

        // When
        let result = try await sut.categorizeWithFallback("Finish the report by Friday")

        // Then
        XCTAssertEqual(result.result.category, .project)
        XCTAssertEqual(result.source, .onDevice)
        XCTAssertEqual(mockOnDevice.categorizeCallCount, 1)
        XCTAssertEqual(mockCloud.categorizeCallCount, 0)
        XCTAssertEqual(mockTrainingRepo.saveCallCount, 0, "No training example should be saved for on-device success")
    }

    // MARK: - Full Flow: Cloud Fallback

    func test_fullFlow_lowConfidence_fallsBackToCloud_storesTraining() async throws {
        // Given: On-device returns low confidence, cloud succeeds
        mockOnDevice.mockIsAvailable = true
        mockOnDevice.mockResult = CategorizationResult(
            category: .resource,
            reasoning: "Uncertain",
            confidence: 0.45
        )
        mockCloud.mockIsAvailable = true
        mockCloud.mockResult = CategorizationResult(
            category: .area,
            reasoning: "Ongoing responsibility with regular review",
            confidence: 0.91
        )

        let sut = CategorizationService(
            onDeviceService: mockOnDevice,
            cloudService: mockCloud,
            trainingRepository: mockTrainingRepo,
            config: CategorizationConfig(confidenceThreshold: 0.8, storeTrainingExamples: true)
        )

        // When
        let result = try await sut.categorizeWithFallback("Weekly health metrics review")

        // Then
        XCTAssertEqual(result.result.category, .area)
        XCTAssertEqual(result.source, .cloud)
        XCTAssertEqual(mockOnDevice.categorizeCallCount, 1)
        XCTAssertEqual(mockCloud.categorizeCallCount, 1)

        // Training example should be stored
        XCTAssertEqual(mockTrainingRepo.saveCallCount, 1)
        XCTAssertEqual(mockTrainingRepo.lastSavedExample?.category, .area)
        XCTAssertEqual(mockTrainingRepo.lastSavedExample?.content, "Weekly health metrics review")
    }

    // MARK: - Full Flow: On-Device Unavailable

    func test_fullFlow_onDeviceUnavailable_usesCloudDirectly() async throws {
        // Given: On-device not available
        mockOnDevice.mockIsAvailable = false
        mockCloud.mockIsAvailable = true
        mockCloud.mockResult = CategorizationResult(
            category: .resource,
            reasoning: "Reference material about programming",
            confidence: 0.88
        )

        let sut = CategorizationService(
            onDeviceService: mockOnDevice,
            cloudService: mockCloud,
            trainingRepository: mockTrainingRepo,
            config: CategorizationConfig(confidenceThreshold: 0.8)
        )

        // When
        let result = try await sut.categorizeWithFallback("Great SwiftUI tutorial I found")

        // Then
        XCTAssertEqual(result.result.category, .resource)
        XCTAssertEqual(result.source, .cloud)
        XCTAssertEqual(mockOnDevice.categorizeCallCount, 0, "On-device should not be called when unavailable")
        XCTAssertEqual(mockCloud.categorizeCallCount, 1)
    }

    // MARK: - Full Flow: Both Services Unavailable

    func test_fullFlow_bothUnavailable_throwsError() async {
        // Given: Both services unavailable
        mockOnDevice.mockIsAvailable = false
        mockCloud.mockIsAvailable = false

        let sut = CategorizationService(
            onDeviceService: mockOnDevice,
            cloudService: mockCloud,
            trainingRepository: mockTrainingRepo
        )

        // When/Then
        do {
            _ = try await sut.categorizeWithFallback("Some note content")
            XCTFail("Should throw when both services unavailable")
        } catch let error as CategorizationError {
            if case .serviceUnavailable = error {
                // Expected
            } else {
                XCTFail("Expected serviceUnavailable error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Full Flow: On-Device Failure with Cloud Recovery

    func test_fullFlow_onDeviceThrows_cloudRecovers() async throws {
        // Given: On-device throws, cloud recovers
        mockOnDevice.mockIsAvailable = true
        mockOnDevice.shouldThrow = CategorizationError.unknown(message: "Model crashed")
        mockCloud.mockIsAvailable = true
        mockCloud.mockResult = CategorizationResult(
            category: .project,
            reasoning: "Contains deadline",
            confidence: 0.87
        )

        let sut = CategorizationService(
            onDeviceService: mockOnDevice,
            cloudService: mockCloud,
            trainingRepository: mockTrainingRepo,
            config: CategorizationConfig(confidenceThreshold: 0.8)
        )

        // When
        let result = try await sut.categorizeWithFallback("Deploy by Monday morning")

        // Then
        XCTAssertEqual(result.result.category, .project)
        XCTAssertEqual(result.source, .cloud)
        XCTAssertEqual(mockOnDevice.categorizeCallCount, 1)
        XCTAssertEqual(mockCloud.categorizeCallCount, 1)
    }

    // MARK: - Content Validation

    func test_fullFlow_emptyContent_throwsError() async {
        // Given
        mockOnDevice.mockIsAvailable = true
        let sut = CategorizationService(
            onDeviceService: mockOnDevice,
            cloudService: mockCloud,
            trainingRepository: mockTrainingRepo
        )

        // When/Then
        do {
            _ = try await sut.categorizeWithFallback("")
            XCTFail("Should throw for empty content")
        } catch let error as CategorizationError {
            if case .invalidContent = error {
                // Expected
            } else {
                XCTFail("Expected invalidContent error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_fullFlow_whitespaceContent_throwsError() async {
        // Given
        mockOnDevice.mockIsAvailable = true
        let sut = CategorizationService(
            onDeviceService: mockOnDevice,
            cloudService: mockCloud,
            trainingRepository: mockTrainingRepo
        )

        // When/Then
        do {
            _ = try await sut.categorizeWithFallback("   \n\t  ")
            XCTFail("Should throw for whitespace-only content")
        } catch let error as CategorizationError {
            if case .invalidContent = error {
                // Expected
            } else {
                XCTFail("Expected invalidContent error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Processing Time

    func test_fullFlow_recordsProcessingTime() async throws {
        // Given
        mockOnDevice.mockIsAvailable = true
        mockOnDevice.mockResult = CategorizationResult(
            category: .project,
            reasoning: "Deadline keyword found",
            confidence: 0.9
        )

        let sut = CategorizationService(
            onDeviceService: mockOnDevice,
            cloudService: mockCloud,
            trainingRepository: mockTrainingRepo
        )

        // When
        let result = try await sut.categorizeWithFallback("Ship the feature by EOD")

        // Then
        XCTAssertGreaterThanOrEqual(result.processingTime, 0)
        XCTAssertLessThan(result.processingTime, 5.0, "Processing should be fast with mocks")
    }

    // MARK: - Configurable Threshold

    func test_fullFlow_customThreshold_respected() async throws {
        // Given: Strict threshold of 0.95
        mockOnDevice.mockIsAvailable = true
        mockOnDevice.mockResult = CategorizationResult(
            category: .project,
            reasoning: "Probably a project",
            confidence: 0.90 // Above default 0.8 but below custom 0.95
        )
        mockCloud.mockIsAvailable = true
        mockCloud.mockResult = CategorizationResult(
            category: .project,
            reasoning: "Definitely a project",
            confidence: 0.97
        )

        let sut = CategorizationService(
            onDeviceService: mockOnDevice,
            cloudService: mockCloud,
            trainingRepository: mockTrainingRepo,
            config: CategorizationConfig(confidenceThreshold: 0.95)
        )

        // When
        let result = try await sut.categorizeWithFallback("Complete sprint tasks")

        // Then: Should fall back to cloud despite 0.90 on-device
        XCTAssertEqual(result.source, .cloud)
        XCTAssertEqual(result.result.confidence, 0.97)
    }

    // MARK: - Training Example Storage Control

    func test_fullFlow_trainingDisabled_doesNotStore() async throws {
        // Given: Training storage disabled
        mockOnDevice.mockIsAvailable = true
        mockOnDevice.mockResult = CategorizationResult(
            category: .resource,
            reasoning: "Uncertain",
            confidence: 0.3
        )
        mockCloud.mockIsAvailable = true
        mockCloud.mockResult = CategorizationResult(
            category: .area,
            reasoning: "Ongoing task",
            confidence: 0.89
        )

        let sut = CategorizationService(
            onDeviceService: mockOnDevice,
            cloudService: mockCloud,
            trainingRepository: mockTrainingRepo,
            config: CategorizationConfig(
                confidenceThreshold: 0.8,
                storeTrainingExamples: false
            )
        )

        // When
        _ = try await sut.categorizeWithFallback("Monthly budget review")

        // Then
        XCTAssertEqual(mockTrainingRepo.saveCallCount, 0, "Should not store when training is disabled")
    }

    // MARK: - End-to-End with CaptureViewModel

    @MainActor
    func test_endToEnd_captureViewModel_saveAndCategorize() async {
        // Given
        let mockRepo = MockNoteRepository()
        mockOnDevice.mockIsAvailable = true
        mockOnDevice.mockResult = CategorizationResult(
            category: .project,
            reasoning: "Deadline detected",
            confidence: 0.95
        )

        let sut = CategorizationService(
            onDeviceService: mockOnDevice,
            cloudService: mockCloud,
            trainingRepository: mockTrainingRepo
        )

        let viewModel = CaptureViewModel(
            noteRepository: mockRepo,
            categorizationService: sut
        )

        // When: Simulate text input and save
        viewModel.inputMode = .text
        viewModel.transcription = "Finish the app review by Friday"
        await viewModel.saveNote()

        // Then: Note should be saved
        XCTAssertEqual(mockRepo.saveCallCount, 1)
        XCTAssertNotNil(viewModel.savedNote)
        XCTAssertTrue(viewModel.showCategorizationSheet)
    }
}
