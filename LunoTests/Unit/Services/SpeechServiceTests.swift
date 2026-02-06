@testable import Luno
import XCTest

/// Unit tests for SpeechService
/// TDD: These tests must fail before implementation
final class SpeechServiceTests: XCTestCase {
    // MARK: - Properties

    var sut: SpeechService!

    // MARK: - Setup

    override func setUp() async throws {
        try await super.setUp()
        sut = SpeechService()
    }

    override func tearDown() async throws {
        await sut.stopRecognition()
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Authorization Tests

    func test_authorizationStatus_initiallyReturnsCurrentStatus() async {
        // When
        let status = await sut.authorizationStatus

        // Then - Status should be one of the valid values
        XCTAssertTrue(
            [.notDetermined, .denied, .restricted, .authorized].contains(status),
            "Status should be a valid SpeechAuthorizationStatus"
        )
    }

    func test_requestAuthorization_returnsStatus() async {
        // When
        let status = await sut.requestAuthorization()

        // Then
        XCTAssertTrue(
            [.notDetermined, .denied, .restricted, .authorized].contains(status),
            "Should return a valid authorization status"
        )
    }

    // MARK: - Recognition State Tests

    func test_isRecognizing_initiallyFalse() async {
        // When
        let isRecognizing = await sut.isRecognizing

        // Then
        XCTAssertFalse(isRecognizing)
    }

    func test_stopRecognition_whenNotRecognizing_doesNotThrow() async {
        // When/Then - Should not throw
        await sut.stopRecognition()
    }

    // MARK: - Transcription Result Tests

    func test_transcriptionResult_initialization() {
        // Given
        let text = "Hello world"
        let timestamp = Date()

        // When
        let result = TranscriptionResult(
            text: text,
            isFinal: true,
            confidence: 0.95,
            timestamp: timestamp
        )

        // Then
        XCTAssertEqual(result.text, text)
        XCTAssertTrue(result.isFinal)
        XCTAssertEqual(result.confidence, 0.95, accuracy: 0.001)
        XCTAssertEqual(result.timestamp, timestamp)
    }

    func test_transcriptionResult_defaultValues() {
        // When
        let result = TranscriptionResult(text: "Test")

        // Then
        XCTAssertEqual(result.text, "Test")
        XCTAssertFalse(result.isFinal)
        XCTAssertEqual(result.confidence, 0.0, accuracy: 0.001)
    }

    func test_transcriptionResult_equatable() {
        // Given
        let timestamp = Date()
        let result1 = TranscriptionResult(text: "Hello", isFinal: true, confidence: 0.9, timestamp: timestamp)
        let result2 = TranscriptionResult(text: "Hello", isFinal: true, confidence: 0.9, timestamp: timestamp)
        let result3 = TranscriptionResult(text: "World", isFinal: true, confidence: 0.9, timestamp: timestamp)

        // Then
        XCTAssertEqual(result1, result2)
        XCTAssertNotEqual(result1, result3)
    }

    // MARK: - Speech Service Error Tests

    func test_speechServiceError_notAuthorized_description() {
        let error = SpeechServiceError.notAuthorized
        XCTAssertEqual(error.errorDescription, "Speech recognition is not authorized.")
    }

    func test_speechServiceError_notAvailable_description() {
        let error = SpeechServiceError.notAvailable
        XCTAssertEqual(error.errorDescription, "Speech recognition is not available on this device.")
    }

    func test_speechServiceError_recognitionFailed_description() {
        let error = SpeechServiceError.recognitionFailed("Timeout")
        XCTAssertEqual(error.errorDescription, "Recognition failed: Timeout")
    }

    func test_speechServiceError_audioSessionFailed_description() {
        let error = SpeechServiceError.audioSessionFailed("Cannot activate")
        XCTAssertEqual(error.errorDescription, "Audio session failed: Cannot activate")
    }

    func test_speechServiceError_alreadyRecognizing_description() {
        let error = SpeechServiceError.alreadyRecognizing
        XCTAssertEqual(error.errorDescription, "Speech recognition is already in progress.")
    }

    func test_speechServiceError_noInputNode_description() {
        let error = SpeechServiceError.noInputNode
        XCTAssertEqual(error.errorDescription, "No audio input node available.")
    }

    // MARK: - Speech Authorization Status Tests

    func test_speechAuthorizationStatus_rawValues() {
        XCTAssertEqual(SpeechAuthorizationStatus.notDetermined.rawValue, "notDetermined")
        XCTAssertEqual(SpeechAuthorizationStatus.denied.rawValue, "denied")
        XCTAssertEqual(SpeechAuthorizationStatus.restricted.rawValue, "restricted")
        XCTAssertEqual(SpeechAuthorizationStatus.authorized.rawValue, "authorized")
    }
}

// MARK: - Mock Speech Service

/// Mock implementation for testing ViewModels
final class MockSpeechService: SpeechServiceProtocol, @unchecked Sendable {
    var mockAuthorizationStatus: SpeechAuthorizationStatus = .authorized
    var mockIsRecognizing: Bool = false
    var mockTranscriptions: [TranscriptionResult] = []
    var shouldThrowOnStart: SpeechServiceError?

    var startRecognitionCallCount = 0
    var stopRecognitionCallCount = 0
    var requestAuthorizationCallCount = 0

    var authorizationStatus: SpeechAuthorizationStatus {
        get async { mockAuthorizationStatus }
    }

    var isRecognizing: Bool {
        get async { mockIsRecognizing }
    }

    func requestAuthorization() async -> SpeechAuthorizationStatus {
        requestAuthorizationCallCount += 1
        return mockAuthorizationStatus
    }

    func startRecognition() async throws -> AsyncThrowingStream<TranscriptionResult, Error> {
        startRecognitionCallCount += 1

        if let error = shouldThrowOnStart {
            throw error
        }

        mockIsRecognizing = true

        return AsyncThrowingStream { continuation in
            Task {
                for transcription in self.mockTranscriptions {
                    continuation.yield(transcription)
                    try? await Task.sleep(nanoseconds: 10_000_000) // 10ms delay
                }
                continuation.finish()
            }
        }
    }

    func stopRecognition() async {
        stopRecognitionCallCount += 1
        mockIsRecognizing = false
    }
}
