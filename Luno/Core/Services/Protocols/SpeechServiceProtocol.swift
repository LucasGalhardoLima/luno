import Combine
import Foundation

// MARK: - Speech Service Protocol

// Protocol for speech recognition service
// Constitution: Use protocols for testability

protocol SpeechServiceProtocol: Sendable {
    /// Current authorization status
    var authorizationStatus: SpeechAuthorizationStatus { get async }

    /// Request speech recognition authorization
    func requestAuthorization() async -> SpeechAuthorizationStatus

    /// Start speech recognition
    /// - Returns: AsyncStream of transcription results
    func startRecognition() async throws -> AsyncThrowingStream<TranscriptionResult, Error>

    /// Stop speech recognition
    func stopRecognition() async

    /// Whether recognition is currently active
    var isRecognizing: Bool { get async }
}

// MARK: - Speech Authorization Status

enum SpeechAuthorizationStatus: String, Sendable {
    case notDetermined
    case denied
    case restricted
    case authorized
}

// MARK: - Transcription Result

struct TranscriptionResult: Sendable, Equatable {
    /// The transcribed text
    let text: String

    /// Whether this is a final result or interim
    let isFinal: Bool

    /// Confidence level (0.0 - 1.0)
    let confidence: Float

    /// Timestamp of the transcription
    let timestamp: Date

    init(
        text: String,
        isFinal: Bool = false,
        confidence: Float = 0.0,
        timestamp: Date = Date()
    ) {
        self.text = text
        self.isFinal = isFinal
        self.confidence = confidence
        self.timestamp = timestamp
    }
}

// MARK: - Speech Service Error

enum SpeechServiceError: LocalizedError, Equatable {
    case notAuthorized
    case notAvailable
    case recognitionFailed(String)
    case audioSessionFailed(String)
    case alreadyRecognizing
    case noInputNode

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            "Speech recognition is not authorized."
        case .notAvailable:
            "Speech recognition is not available on this device."
        case let .recognitionFailed(message):
            "Recognition failed: \(message)"
        case let .audioSessionFailed(message):
            "Audio session failed: \(message)"
        case .alreadyRecognizing:
            "Speech recognition is already in progress."
        case .noInputNode:
            "No audio input node available."
        }
    }
}
