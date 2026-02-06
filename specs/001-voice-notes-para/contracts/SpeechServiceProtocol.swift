// MARK: - SpeechServiceProtocol
// Contract for speech recognition operations

import Foundation
import Combine

/// Protocol defining speech-to-text operations
/// Implementations: SpeechService (Apple Speech framework)
protocol SpeechServiceProtocol {

    // MARK: - Authorization

    /// Checks current authorization status
    var authorizationStatus: SpeechAuthorizationStatus { get }

    /// Requests speech recognition permission from user
    /// - Returns: Whether permission was granted
    func requestAuthorization() async -> Bool

    // MARK: - Recognition State

    /// Whether recognition is currently active
    var isRecording: Bool { get }

    /// Publisher for real-time transcription updates
    var transcriptionPublisher: AnyPublisher<TranscriptionUpdate, Never> { get }

    // MARK: - Recording Control

    /// Starts speech recognition
    /// - Throws: SpeechError if recognition cannot start
    func startRecording() async throws

    /// Stops speech recognition and finalizes transcription
    /// - Returns: Final transcribed text
    func stopRecording() async -> String

    /// Cancels ongoing recognition without returning result
    func cancelRecording()
}

// MARK: - Supporting Types

enum SpeechAuthorizationStatus {
    case notDetermined
    case authorized
    case denied
    case restricted  // Parental controls, etc.
}

struct TranscriptionUpdate {
    /// Current transcribed text (may be partial)
    let text: String

    /// Whether this is the final result
    let isFinal: Bool

    /// Confidence level (0.0 to 1.0)
    let confidence: Float

    /// Segments with timing info (for UI feedback)
    let segments: [TranscriptionSegment]
}

struct TranscriptionSegment {
    let text: String
    let timestamp: TimeInterval
    let duration: TimeInterval
    let confidence: Float
}

enum SpeechError: Error, LocalizedError {
    case notAuthorized
    case recognizerUnavailable
    case audioSessionFailed(underlying: Error)
    case recognitionFailed(underlying: Error)
    case recordingInProgress
    case deviceNotSupported

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Speech recognition permission not granted"
        case .recognizerUnavailable:
            return "Speech recognizer not available for this language"
        case .audioSessionFailed(let error):
            return "Audio session error: \(error.localizedDescription)"
        case .recognitionFailed(let error):
            return "Recognition failed: \(error.localizedDescription)"
        case .recordingInProgress:
            return "Recording already in progress"
        case .deviceNotSupported:
            return "Speech recognition not supported on this device"
        }
    }
}
