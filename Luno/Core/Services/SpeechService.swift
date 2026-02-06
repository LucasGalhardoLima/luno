import AVFoundation
import Foundation
import os
import Speech

// MARK: - Speech Service

// Apple Speech framework implementation for voice recognition
// Constitution: Use native Apple frameworks for best integration

actor SpeechService: SpeechServiceProtocol {
    // MARK: - Properties

    private let log = LunoLogger.speech
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    private var _isRecognizing = false

    /// Pause detection timer interval (seconds)
    private let pauseDetectionInterval: TimeInterval = 2.0
    private var lastSpeechTime: Date?

    // MARK: - Initialization

    init(locale: Locale = .current) {
        speechRecognizer = SFSpeechRecognizer(locale: locale)
    }

    // MARK: - SpeechServiceProtocol

    var authorizationStatus: SpeechAuthorizationStatus {
        get async {
            mapAuthorizationStatus(SFSpeechRecognizer.authorizationStatus())
        }
    }

    var isRecognizing: Bool {
        get async { _isRecognizing }
    }

    func requestAuthorization() async -> SpeechAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: self.mapAuthorizationStatus(status))
            }
        }
    }

    func startRecognition() async throws -> AsyncThrowingStream<TranscriptionResult, Error> {
        let components = try await prepareRecognition()

        _isRecognizing = true
        lastSpeechTime = Date()

        return AsyncThrowingStream { continuation in
            components.inputNode.installTap(onBus: 0, bufferSize: 1024, format: components.recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }

            do {
                try self.audioEngine.start()
            } catch {
                continuation.finish(throwing: SpeechServiceError.audioSessionFailed(error.localizedDescription))
                return
            }

            self.recognitionTask = components.recognizer.recognitionTask(with: components.request) { result, error in
                self.handleRecognitionResult(result: result, error: error, continuation: continuation)
            }

            continuation.onTermination = { @Sendable _ in
                Task { await self.cleanupRecognition() }
            }
        }
    }

    // MARK: - Recognition Helpers

    private struct RecognitionComponents {
        let recognizer: SFSpeechRecognizer
        let request: SFSpeechAudioBufferRecognitionRequest
        let inputNode: AVAudioInputNode
        let recordingFormat: AVAudioFormat
    }

    private func prepareRecognition() async throws -> RecognitionComponents {
        guard !_isRecognizing else {
            log.warning("Attempted to start recognition while already recognizing")
            throw SpeechServiceError.alreadyRecognizing
        }

        guard let speechRecognizer, speechRecognizer.isAvailable else {
            log.error("Speech recognizer not available")
            throw SpeechServiceError.notAvailable
        }

        let status = await authorizationStatus
        guard status == .authorized else {
            log.error("Speech recognition not authorized, status: \(String(describing: status))")
            throw SpeechServiceError.notAuthorized
        }

        log.info("Starting speech recognition")
        try await configureAudioSession()

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else {
            throw SpeechServiceError.recognitionFailed("Failed to create recognition request")
        }
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.addsPunctuation = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        guard recordingFormat.sampleRate > 0 else {
            throw SpeechServiceError.noInputNode
        }

        return RecognitionComponents(
            recognizer: speechRecognizer,
            request: recognitionRequest,
            inputNode: inputNode,
            recordingFormat: recordingFormat
        )
    }

    nonisolated private func handleRecognitionResult(
        result: SFSpeechRecognitionResult?,
        error: Error?,
        continuation: AsyncThrowingStream<TranscriptionResult, Error>.Continuation
    ) {
        if let error {
            let nsError = error as NSError
            if nsError.domain == "kAFAssistantErrorDomain", nsError.code == 216 {
                continuation.finish()
            } else {
                continuation.finish(throwing: SpeechServiceError.recognitionFailed(error.localizedDescription))
            }
            return
        }

        if let result {
            let transcription = TranscriptionResult(
                text: result.bestTranscription.formattedString,
                isFinal: result.isFinal,
                confidence: calculateConfidence(from: result),
                timestamp: Date()
            )
            continuation.yield(transcription)

            if result.isFinal {
                continuation.finish()
            }
        }
    }

    func stopRecognition() async {
        log.info("Stopping speech recognition")
        await cleanupRecognition()
    }

    // MARK: - Private Methods

    private func configureAudioSession() async throws {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            log.debug("Audio session configured successfully")
        } catch {
            log.error("Audio session configuration failed: \(error.localizedDescription)")
            throw SpeechServiceError.audioSessionFailed(error.localizedDescription)
        }
    }

    private func cleanupRecognition() {
        recognitionTask?.cancel()
        recognitionTask = nil

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        _isRecognizing = false

        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func mapAuthorizationStatus(_ status: SFSpeechRecognizerAuthorizationStatus) -> SpeechAuthorizationStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .authorized:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }

    nonisolated private func calculateConfidence(from result: SFSpeechRecognitionResult) -> Float {
        let segments = result.bestTranscription.segments
        guard !segments.isEmpty else { return 0 }

        let totalConfidence = segments.reduce(0.0) { $0 + $1.confidence }
        return totalConfidence / Float(segments.count)
    }
}
