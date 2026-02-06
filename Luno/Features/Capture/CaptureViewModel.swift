import Foundation
import SwiftUI

// MARK: - Capture View Model

// ViewModel for voice and text note capture
// Constitution: MVVM with clear separation of concerns

@MainActor
@Observable
final class CaptureViewModel {
    // MARK: - Properties

    /// Current capture state
    var captureState: CaptureState = .idle

    /// Current transcription text
    var transcription: String = ""

    /// Current error
    var error: AppError?

    /// Input mode (voice or text)
    var inputMode: InputMode = .voice

    /// Whether speech recognition is authorized
    var isAuthorized: Bool = false

    /// The saved note (for categorization flow)
    var savedNote: Note?

    /// Whether to show categorization sheet
    var showCategorizationSheet: Bool = false

    /// Categorization result for the sheet
    var categorizationResult: CategorizedNote?

    /// Whether categorization is in progress
    var isCategorizing: Bool = false

    // MARK: - Dependencies

    private let speechService: any SpeechServiceProtocol
    private let noteRepository: any NoteRepositoryProtocol
    private let categorizationService: (any CategorizationOrchestratorProtocol)?

    // MARK: - Private State

    private var recognitionTask: Task<Void, Never>?

    // MARK: - Initialization

    init(
        speechService: any SpeechServiceProtocol = SpeechService(),
        noteRepository: any NoteRepositoryProtocol,
        categorizationService: (any CategorizationOrchestratorProtocol)? = nil
    ) {
        self.speechService = speechService
        self.noteRepository = noteRepository
        self.categorizationService = categorizationService
    }

    // MARK: - Authorization

    func checkAuthorization() async {
        let status = await speechService.authorizationStatus
        isAuthorized = status == .authorized
    }

    func requestAuthorization() async {
        let status = await speechService.requestAuthorization()
        isAuthorized = status == .authorized

        if status == .denied {
            error = .speechPermissionDenied
        }
    }

    // MARK: - Recording

    func startRecording() async {
        guard captureState != .recording else { return }

        // Check authorization first
        let status = await speechService.authorizationStatus
        guard status == .authorized else {
            error = .speechPermissionDenied
            return
        }

        captureState = .recording
        error = nil

        recognitionTask = Task {
            do {
                let stream = try await speechService.startRecognition()

                for try await result in stream {
                    guard !Task.isCancelled else { break }
                    transcription = result.text

                    if result.isFinal {
                        captureState = .reviewing
                    }
                }
            } catch let speechError as SpeechServiceError {
                handleSpeechError(speechError)
            } catch {
                self.error = .unknown(error.localizedDescription)
            }

            if captureState == .recording {
                captureState = transcription.isEmpty ? .idle : .reviewing
            }
        }
    }

    func stopRecording() async {
        recognitionTask?.cancel()
        recognitionTask = nil

        await speechService.stopRecognition()

        if captureState == .recording {
            captureState = transcription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? .idle
                : .reviewing
        }
    }

    // MARK: - Save & Discard

    func saveNote() async {
        let trimmedContent = transcription.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return }

        captureState = .saving

        let note = Note(
            content: trimmedContent,
            sourceType: inputMode == .voice ? .voice : .text,
            category: .uncategorized
        )

        do {
            try await noteRepository.save(note)
            savedNote = note
            categorizationResult = nil
            resetCapture()
            showCategorizationSheet = true

            // Trigger async categorization in background
            await categorizeNote(note)
        } catch {
            self.error = .saveFailed(error.localizedDescription)
            captureState = .reviewing
        }
    }

    /// Apply a category chosen by the user from the categorization sheet
    func applyCategory(_ category: PARACategory, to note: Note) async {
        note.category = category
        do {
            try await noteRepository.update(note)
        } catch {
            self.error = .saveFailed(error.localizedDescription)
        }
    }

    // MARK: - Categorization

    private func categorizeNote(_ note: Note) async {
        guard let service = categorizationService else { return }

        let available = await service.isAvailable
        guard available else { return }

        isCategorizing = true
        defer { isCategorizing = false }

        do {
            let result = try await service.categorizeWithFallback(note.content)
            categorizationResult = result
        } catch {
            // Non-critical: user can still pick a category manually
            categorizationResult = nil
        }
    }

    func discardNote() {
        resetCapture()
    }

    // MARK: - Input Mode

    func toggleInputMode() {
        inputMode = inputMode == .voice ? .text : .voice
    }

    // MARK: - Error Handling

    func clearError() {
        error = nil
    }

    // MARK: - Private Methods

    private func resetCapture() {
        transcription = ""
        captureState = .idle
    }

    private func handleSpeechError(_ speechError: SpeechServiceError) {
        switch speechError {
        case .notAuthorized:
            error = .speechPermissionDenied
        case .notAvailable:
            error = .speechRecognitionUnavailable
        case let .recognitionFailed(message):
            error = .unknown("Recognition failed: \(message)")
        case let .audioSessionFailed(message):
            error = .unknown("Audio error: \(message)")
        case .alreadyRecognizing:
            // Ignore - this shouldn't happen with proper state management
            break
        case .noInputNode:
            error = .microphonePermissionDenied
        }

        captureState = transcription.isEmpty ? .idle : .reviewing
    }
}

// MARK: - Capture State

enum CaptureState: Equatable {
    case idle
    case recording
    case reviewing
    case saving
}

// MARK: - Input Mode

enum InputMode: String, CaseIterable {
    case voice
    case text

    var iconName: String {
        switch self {
        case .voice:
            "mic.fill"
        case .text:
            "keyboard"
        }
    }

    var label: String {
        switch self {
        case .voice:
            "Voice"
        case .text:
            "Type"
        }
    }
}
