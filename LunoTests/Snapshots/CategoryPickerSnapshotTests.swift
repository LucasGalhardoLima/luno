@testable import Luno
import SnapshotTesting
import SwiftUI
import XCTest

/// Snapshot tests for CategoryPickerView
/// TDD: Visual regression testing for category selection UI
final class CategoryPickerSnapshotTests: XCTestCase {
    // MARK: - Default State

    func test_categoryPicker_projectSelected() {
        let view = CategoryPickerView(currentCategory: .project) { _ in }

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 500)

        assertSnapshot(of: controller, as: .image)
    }

    func test_categoryPicker_areaSelected() {
        let view = CategoryPickerView(currentCategory: .area) { _ in }

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 500)

        assertSnapshot(of: controller, as: .image)
    }

    func test_categoryPicker_resourceSelected() {
        let view = CategoryPickerView(currentCategory: .resource) { _ in }

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 500)

        assertSnapshot(of: controller, as: .image)
    }

    func test_categoryPicker_archiveSelected() {
        let view = CategoryPickerView(currentCategory: .archive) { _ in }

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 500)

        assertSnapshot(of: controller, as: .image)
    }

    func test_categoryPicker_uncategorized() {
        let view = CategoryPickerView(currentCategory: .uncategorized) { _ in }

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 500)

        assertSnapshot(of: controller, as: .image)
    }

    // MARK: - Dark Mode

    func test_categoryPicker_darkMode() {
        let view = CategoryPickerView(currentCategory: .project) { _ in }
            .environment(\.colorScheme, .dark)

        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .dark
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 500)

        assertSnapshot(of: controller, as: .image)
    }
}
