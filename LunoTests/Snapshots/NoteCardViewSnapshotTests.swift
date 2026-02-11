@testable import Luno
import SnapshotTesting
import SwiftUI
import XCTest

/// Snapshot tests for NoteCard view
/// TDD: Visual regression testing for note card display
final class NoteCardViewSnapshotTests: XCTestCase {
    // MARK: - Configuration

    /// Fixed date for deterministic snapshots
    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000) // Nov 14, 2023
    private let shouldRecord = ProcessInfo.processInfo.environment["SNAPSHOT_TESTING_RECORD"] == "all"

    // MARK: - Basic Card

    func test_noteCard_voiceNote() {
        let note = Note(
            content: "Finish landing page redesign by Friday. Coordinate with design team.",
            sourceType: .voice,
            category: .project,
            categoryConfidence: 0.92,
            createdAt: fixedDate,
            modifiedAt: fixedDate
        )

        let view = NoteCard(note: note)
            .padding(LunoTheme.Spacing.md)
            .frame(width: 375)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 375, height: 200)

        assertSnapshot(of: controller, as: .image, record: shouldRecord)
    }

    func test_noteCard_textNote() {
        let note = Note(
            content: "Weekly health metrics review and exercise tracking notes.",
            sourceType: .text,
            category: .area,
            categoryConfidence: 0.85,
            createdAt: fixedDate,
            modifiedAt: fixedDate
        )

        let view = NoteCard(note: note)
            .padding(LunoTheme.Spacing.md)
            .frame(width: 375)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 375, height: 200)

        assertSnapshot(of: controller, as: .image, record: shouldRecord)
    }

    // MARK: - Pinned Note

    func test_noteCard_pinned() {
        let note = Note(
            content: "Important: Shipping deadline next week. Must complete review.",
            sourceType: .voice,
            category: .project,
            isPinned: true,
            createdAt: fixedDate,
            modifiedAt: fixedDate
        )

        let view = NoteCard(note: note)
            .padding(LunoTheme.Spacing.md)
            .frame(width: 375)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 375, height: 200)

        assertSnapshot(of: controller, as: .image, record: shouldRecord)
    }

    // MARK: - All PARA Categories

    func test_noteCard_resourceCategory() {
        let note = Note(
            content: "Great article about SwiftUI performance optimization techniques.",
            sourceType: .text,
            category: .resource,
            createdAt: fixedDate,
            modifiedAt: fixedDate
        )

        let view = NoteCard(note: note)
            .padding(LunoTheme.Spacing.md)
            .frame(width: 375)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 375, height: 200)

        assertSnapshot(of: controller, as: .image, record: shouldRecord)
    }

    func test_noteCard_archiveCategory() {
        let note = Note(
            content: "Q3 marketing campaign completed successfully. All goals met.",
            sourceType: .voice,
            category: .archive,
            createdAt: fixedDate,
            modifiedAt: fixedDate
        )

        let view = NoteCard(note: note)
            .padding(LunoTheme.Spacing.md)
            .frame(width: 375)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 375, height: 200)

        assertSnapshot(of: controller, as: .image, record: shouldRecord)
    }

    func test_noteCard_uncategorized() {
        let note = Note(
            content: "Random thought about something interesting I heard today.",
            sourceType: .voice,
            category: .uncategorized,
            createdAt: fixedDate,
            modifiedAt: fixedDate
        )

        let view = NoteCard(note: note)
            .padding(LunoTheme.Spacing.md)
            .frame(width: 375)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 375, height: 200)

        assertSnapshot(of: controller, as: .image, record: shouldRecord)
    }

    // MARK: - Long Content

    func test_noteCard_longContent() {
        let note = Note(
            content: "This is a very long note that should be truncated after three lines. It contains a lot of text to verify that the card properly limits the content preview. The card should show an ellipsis at the end of the third line to indicate there is more content available.",
            sourceType: .text,
            category: .project,
            createdAt: fixedDate,
            modifiedAt: fixedDate
        )

        let view = NoteCard(note: note)
            .padding(LunoTheme.Spacing.md)
            .frame(width: 375)
            .background(LunoColors.background)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 375, height: 200)

        assertSnapshot(of: controller, as: .image, record: shouldRecord)
    }

    // MARK: - Dark Mode

    func test_noteCard_darkMode() {
        let note = Note(
            content: "Finish landing page redesign by Friday.",
            sourceType: .voice,
            category: .project,
            isPinned: true,
            createdAt: fixedDate,
            modifiedAt: fixedDate
        )

        let view = NoteCard(note: note)
            .padding(LunoTheme.Spacing.md)
            .frame(width: 375)
            .background(LunoColors.background)
            .environment(\.colorScheme, .dark)

        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .dark
        controller.view.frame = CGRect(x: 0, y: 0, width: 375, height: 200)

        assertSnapshot(of: controller, as: .image, record: shouldRecord)
    }
}
