@testable import Luno
import SnapshotTesting
import SwiftUI
import XCTest

/// Snapshot tests for FolderCardView
/// TDD: Visual regression testing for PARA folder cards
final class FolderCardViewSnapshotTests: XCTestCase {
    // MARK: - Individual Cards

    func test_folderCard_project() {
        let view = FolderCardView(category: .project, noteCount: 5) {}
            .frame(width: 180)
            .padding(LunoTheme.Spacing.md)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 220, height: 180)

        assertSnapshot(of: controller, as: .image)
    }

    func test_folderCard_area() {
        let view = FolderCardView(category: .area, noteCount: 12) {}
            .frame(width: 180)
            .padding(LunoTheme.Spacing.md)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 220, height: 180)

        assertSnapshot(of: controller, as: .image)
    }

    func test_folderCard_resource() {
        let view = FolderCardView(category: .resource, noteCount: 8) {}
            .frame(width: 180)
            .padding(LunoTheme.Spacing.md)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 220, height: 180)

        assertSnapshot(of: controller, as: .image)
    }

    func test_folderCard_archive() {
        let view = FolderCardView(category: .archive, noteCount: 23) {}
            .frame(width: 180)
            .padding(LunoTheme.Spacing.md)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 220, height: 180)

        assertSnapshot(of: controller, as: .image)
    }

    // MARK: - Edge Cases

    func test_folderCard_zeroCount() {
        let view = FolderCardView(category: .project, noteCount: 0) {}
            .frame(width: 180)
            .padding(LunoTheme.Spacing.md)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 220, height: 180)

        assertSnapshot(of: controller, as: .image)
    }

    func test_folderCard_highCount() {
        let view = FolderCardView(category: .area, noteCount: 999) {}
            .frame(width: 180)
            .padding(LunoTheme.Spacing.md)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 220, height: 180)

        assertSnapshot(of: controller, as: .image)
    }

    // MARK: - Grid Layout

    func test_folderCards_gridLayout() {
        let view = LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: LunoTheme.Spacing.md
        ) {
            FolderCardView(category: .project, noteCount: 5) {}
            FolderCardView(category: .area, noteCount: 12) {}
            FolderCardView(category: .resource, noteCount: 8) {}
            FolderCardView(category: .archive, noteCount: 23) {}
        }
        .padding(LunoTheme.Spacing.md)
        .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 350)

        assertSnapshot(of: controller, as: .image)
    }

    // MARK: - Dark Mode

    func test_folderCard_darkMode() {
        let view = FolderCardView(category: .project, noteCount: 5) {}
            .frame(width: 180)
            .padding(LunoTheme.Spacing.md)
            .background(LunoColors.background)
            .environment(\.colorScheme, .dark)

        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .dark
        controller.view.frame = CGRect(x: 0, y: 0, width: 220, height: 180)

        assertSnapshot(of: controller, as: .image)
    }
}
