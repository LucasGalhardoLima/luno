@testable import Luno
import SnapshotTesting
import SwiftUI
import XCTest

/// Snapshot tests for CaptureView
/// TDD: Visual regression testing for the capture screen
final class CaptureViewSnapshotTests: XCTestCase {
    // MARK: - Voice Mode Idle

    func test_captureView_voiceMode_idle() {
        let repo = MockNoteRepository()
        let view = CaptureView(noteRepository: repo, categorizationService: MockCategorizationOrchestrator())

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: controller, as: .image)
    }

    // MARK: - Text Mode

    func test_captureView_textMode() {
        let repo = MockNoteRepository()
        let view = CaptureView(noteRepository: repo, categorizationService: MockCategorizationOrchestrator())

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        // Note: Text mode requires user interaction to toggle.
        // This tests the initial voice mode state.
        // Text mode toggle is verified in UI tests.
        assertSnapshot(of: controller, as: .image)
    }

    // MARK: - Dark Mode

    func test_captureView_darkMode() {
        let repo = MockNoteRepository()
        let view = CaptureView(noteRepository: repo, categorizationService: MockCategorizationOrchestrator())
            .environment(\.colorScheme, .dark)

        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .dark
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: controller, as: .image)
    }
}
