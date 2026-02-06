@testable import Luno
import SnapshotTesting
import SwiftUI
import XCTest

/// Snapshot tests for RecordButton states
/// TDD: Visual regression testing for the main recording button
final class RecordButtonSnapshotTests: XCTestCase {
    // MARK: - Idle State

    func test_recordButton_idle() {
        let view = RecordButton(isRecording: false) {}
            .padding(40)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 200, height: 200)

        assertSnapshot(of: controller, as: .image(on: .iPhone13))
    }

    // MARK: - Recording State

    func test_recordButton_recording() {
        let view = RecordButton(isRecording: true) {}
            .padding(40)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 200, height: 200)

        assertSnapshot(of: controller, as: .image(on: .iPhone13))
    }

    // MARK: - Disabled State

    func test_recordButton_disabled() {
        let view = RecordButton(isRecording: false, isDisabled: true) {}
            .padding(40)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 200, height: 200)

        assertSnapshot(of: controller, as: .image(on: .iPhone13))
    }

    // MARK: - Dark Mode

    func test_recordButton_idle_darkMode() {
        let view = RecordButton(isRecording: false) {}
            .padding(40)
            .background(LunoColors.background)
            .environment(\.colorScheme, .dark)

        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .dark
        controller.view.frame = CGRect(x: 0, y: 0, width: 200, height: 200)

        assertSnapshot(of: controller, as: .image(on: .iPhone13))
    }
}
