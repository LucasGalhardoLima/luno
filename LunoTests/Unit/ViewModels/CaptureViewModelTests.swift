@testable import Luno
import XCTest

/// Unit tests for CaptureViewModel
/// TDD: These tests must fail before implementation
@MainActor
final class CaptureViewModelTests: XCTestCase {
    // MARK: - Properties

    var sut: CaptureViewModel!
    var mockSpeechService: MockSpeechService!
    var mockNoteRepository: MockNoteRepository!

    // MARK: - Setup

    override func setUp() async throws {
        try await super.setUp()
        mockSpeechService = MockSpeechService()
        mockNoteRepository = MockNoteRepository()
        sut = CaptureViewModel(
            speechService: mockSpeechService,
            noteRepository: mockNoteRepository
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockSpeechService = nil
        mockNoteRepository = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func test_initialState_isIdle() {
        XCTAssertEqual(sut.captureState, .idle)
    }

    func test_initialState_transcriptionIsEmpty() {
        XCTAssertTrue(sut.transcription.isEmpty)
    }

    func test_initialState_errorIsNil() {
        XCTAssertNil(sut.error)
    }

    func test_initialState_inputModeIsVoice() {
        XCTAssertEqual(sut.inputMode, .voice)
    }

    // MARK: - Authorization Tests

    func test_checkAuthorization_whenAuthorized_setsAuthorizedTrue() async {
        // Given
        mockSpeechService.mockAuthorizationStatus = .authorized

        // When
        await sut.checkAuthorization()

        // Then
        XCTAssertTrue(sut.isAuthorized)
    }

    func test_checkAuthorization_whenDenied_setsAuthorizedFalse() async {
        // Given
        mockSpeechService.mockAuthorizationStatus = .denied

        // When
        await sut.checkAuthorization()

        // Then
        XCTAssertFalse(sut.isAuthorized)
    }

    func test_requestAuthorization_callsSpeechService() async {
        // When
        await sut.requestAuthorization()

        // Then
        XCTAssertEqual(mockSpeechService.requestAuthorizationCallCount, 1)
    }

    // MARK: - Recording Tests

    func test_startRecording_setsStateToRecording() async {
        // Given
        mockSpeechService.mockAuthorizationStatus = .authorized
        mockSpeechService.mockTranscriptions = [
            TranscriptionResult(text: "Hello", isFinal: false)
        ]

        // When
        await sut.startRecording()

        // Allow async stream to process
        try? await Task.sleep(nanoseconds: 50_000_000)

        // Then
        XCTAssertEqual(sut.captureState, .recording)
    }

    func test_startRecording_callsSpeechService() async {
        // Given
        mockSpeechService.mockAuthorizationStatus = .authorized

        // When
        await sut.startRecording()

        // Then
        XCTAssertEqual(mockSpeechService.startRecognitionCallCount, 1)
    }

    func test_startRecording_updatesTranscription() async {
        // Given
        mockSpeechService.mockAuthorizationStatus = .authorized
        mockSpeechService.mockTranscriptions = [
            TranscriptionResult(text: "Hello", isFinal: false),
            TranscriptionResult(text: "Hello world", isFinal: true)
        ]

        // When
        await sut.startRecording()

        // Allow async stream to process
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.transcription, "Hello world")
    }

    func test_startRecording_whenNotAuthorized_setsError() async {
        // Given
        mockSpeechService.mockAuthorizationStatus = .denied
        mockSpeechService.shouldThrowOnStart = .notAuthorized

        // When
        await sut.startRecording()

        // Then
        XCTAssertNotNil(sut.error)
    }

    func test_stopRecording_setsStateToReviewing() async {
        // Given
        mockSpeechService.mockAuthorizationStatus = .authorized
        sut.transcription = "Some transcription"
        await sut.startRecording()

        // When
        await sut.stopRecording()

        // Then
        XCTAssertEqual(sut.captureState, .reviewing)
    }

    func test_stopRecording_callsSpeechService() async {
        // Given
        await sut.startRecording()

        // When
        await sut.stopRecording()

        // Then
        XCTAssertEqual(mockSpeechService.stopRecognitionCallCount, 1)
    }

    // MARK: - Save Tests

    func test_saveNote_callsRepository() async {
        // Given
        sut.transcription = "Test note content"

        // When
        await sut.saveNote()

        // Then
        XCTAssertEqual(mockNoteRepository.saveCallCount, 1)
    }

    func test_saveNote_createsNoteWithCorrectContent() async {
        // Given
        sut.transcription = "Test note content"

        // When
        await sut.saveNote()

        // Then
        XCTAssertEqual(mockNoteRepository.lastSavedNote?.content, "Test note content")
    }

    func test_saveNote_setsSourceTypeToVoice_whenInVoiceMode() async {
        // Given
        sut.inputMode = .voice
        sut.transcription = "Voice note"

        // When
        await sut.saveNote()

        // Then
        XCTAssertEqual(mockNoteRepository.lastSavedNote?.sourceType, .voice)
    }

    func test_saveNote_setsSourceTypeToText_whenInTextMode() async {
        // Given
        sut.inputMode = .text
        sut.transcription = "Text note"

        // When
        await sut.saveNote()

        // Then
        XCTAssertEqual(mockNoteRepository.lastSavedNote?.sourceType, .text)
    }

    func test_saveNote_resetsStateToIdle() async {
        // Given
        sut.transcription = "Test note"

        // When
        await sut.saveNote()

        // Then
        XCTAssertEqual(sut.captureState, .idle)
    }

    func test_saveNote_clearsTranscription() async {
        // Given
        sut.transcription = "Test note"

        // When
        await sut.saveNote()

        // Then
        XCTAssertTrue(sut.transcription.isEmpty)
    }

    func test_saveNote_withEmptyTranscription_doesNotSave() async {
        // Given
        sut.transcription = ""

        // When
        await sut.saveNote()

        // Then
        XCTAssertEqual(mockNoteRepository.saveCallCount, 0)
    }

    func test_saveNote_withWhitespaceOnlyTranscription_doesNotSave() async {
        // Given
        sut.transcription = "   \n\t  "

        // When
        await sut.saveNote()

        // Then
        XCTAssertEqual(mockNoteRepository.saveCallCount, 0)
    }

    // MARK: - Discard Tests

    func test_discardNote_clearsTranscription() {
        // Given
        sut.transcription = "Test note"

        // When
        sut.discardNote()

        // Then
        XCTAssertTrue(sut.transcription.isEmpty)
    }

    func test_discardNote_resetsStateToIdle() {
        // Given
        sut.transcription = "Test note"
        sut.captureState = .reviewing

        // When
        sut.discardNote()

        // Then
        XCTAssertEqual(sut.captureState, .idle)
    }

    // MARK: - Input Mode Tests

    func test_toggleInputMode_switchesFromVoiceToText() {
        // Given
        sut.inputMode = .voice

        // When
        sut.toggleInputMode()

        // Then
        XCTAssertEqual(sut.inputMode, .text)
    }

    func test_toggleInputMode_switchesFromTextToVoice() {
        // Given
        sut.inputMode = .text

        // When
        sut.toggleInputMode()

        // Then
        XCTAssertEqual(sut.inputMode, .voice)
    }

    func test_toggleInputMode_preservesTranscription() {
        // Given
        sut.transcription = "Keep this content"
        sut.inputMode = .voice

        // When
        sut.toggleInputMode()

        // Then
        XCTAssertEqual(sut.transcription, "Keep this content")
    }

    // MARK: - Error Handling Tests

    func test_clearError_setsErrorToNil() {
        // Given
        sut.error = .speechRecognitionUnavailable

        // When
        sut.clearError()

        // Then
        XCTAssertNil(sut.error)
    }
}

// MockNoteRepository is defined in Luno/Shared/Preview/PreviewHelpers.swift
// and is available in tests via @testable import Luno
