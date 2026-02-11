import Foundation
import SwiftUI

// MARK: - App State

// Global application state observable
// Constitution: Clean architecture with observable state

@Observable
final class AppState {
    // MARK: - Onboarding

    /// Whether the user has completed onboarding
    var onboardingCompleted: Bool = UserDefaults.standard.bool(forKey: "luno.onboarding.completed")

    func completeOnboarding() {
        onboardingCompleted = true
        UserDefaults.standard.set(true, forKey: "luno.onboarding.completed")
    }

    // MARK: - Navigation

    /// Currently selected tab
    var selectedTab: AppTab = .capture

    // MARK: - Data

    /// Incremented when notes data changes, triggers view refreshes
    var dataVersion: Int = 0

    func notifyDataChanged() {
        dataVersion += 1
    }

    // MARK: - UI State

    /// Whether the app is currently recording
    var isRecording: Bool = false

    /// Whether a note is being saved
    var isSaving: Bool = false

    /// Whether categorization is in progress
    var isCategorizing: Bool = false

    // MARK: - Error Handling

    /// Current error to display
    var currentError: AppError?

    /// Whether to show error alert
    var showErrorAlert: Bool = false

    // MARK: - Methods

    func showError(_ error: AppError) {
        currentError = error
        showErrorAlert = true
    }

    func clearError() {
        currentError = nil
        showErrorAlert = false
    }
}

// MARK: - App Tab

enum AppTab: String, CaseIterable {
    case capture
    case notes
    case folders

    var title: String {
        switch self {
        case .capture:
            "Capture"
        case .notes:
            "Notes"
        case .folders:
            "Folders"
        }
    }

    var iconName: String {
        switch self {
        case .capture:
            "mic.fill"
        case .notes:
            "note.text"
        case .folders:
            "folder.fill"
        }
    }
}

// MARK: - App Error

enum AppError: LocalizedError, Equatable {
    case speechRecognitionUnavailable
    case microphonePermissionDenied
    case speechPermissionDenied
    case saveFailed(String)
    case categorizationFailed(String)
    case networkError(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .speechRecognitionUnavailable:
            "Speech recognition is not available on this device."
        case .microphonePermissionDenied:
            "Microphone access is required to record voice notes."
        case .speechPermissionDenied:
            "Speech recognition permission is required to transcribe voice notes."
        case let .saveFailed(message):
            "Failed to save note: \(message)"
        case let .categorizationFailed(message):
            "Failed to categorize note: \(message)"
        case let .networkError(message):
            "Network error: \(message)"
        case let .unknown(message):
            "An error occurred: \(message)"
        }
    }
}
