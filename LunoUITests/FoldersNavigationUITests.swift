import XCTest

/// UI tests for folder navigation (T073)
/// Tests browsing PARA folders and navigating into folder contents
final class FoldersNavigationUITests: XCTestCase {
    // MARK: - Properties

    var app: XCUIApplication!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Tab Navigation

    func test_foldersTab_isAccessible() {
        // Tap Folders tab
        let foldersTab = app.tabBars.buttons["Folders"]
        XCTAssertTrue(foldersTab.waitForExistence(timeout: 5))
        foldersTab.tap()

        // Verify navigation title
        XCTAssertTrue(app.navigationBars["Folders"].waitForExistence(timeout: 3))
    }

    func test_foldersTab_showsTotalNoteCount() {
        // Navigate to Folders tab
        let foldersTab = app.tabBars.buttons["Folders"]
        XCTAssertTrue(foldersTab.waitForExistence(timeout: 5))
        foldersTab.tap()

        // Total Notes label should be visible
        let totalLabel = app.staticTexts["Total Notes"]
        XCTAssertTrue(totalLabel.waitForExistence(timeout: 3))
    }

    func test_foldersTab_showsAllPARAFolders() {
        // Navigate to Folders tab
        let foldersTab = app.tabBars.buttons["Folders"]
        XCTAssertTrue(foldersTab.waitForExistence(timeout: 5))
        foldersTab.tap()

        // All 4 PARA folder cards should be visible
        let projectFolder = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Projects folder'")).firstMatch
        let areaFolder = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Areas folder'")).firstMatch
        let resourceFolder = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Resources folder'")).firstMatch
        let archiveFolder = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Archive folder'")).firstMatch

        XCTAssertTrue(projectFolder.waitForExistence(timeout: 3))
        XCTAssertTrue(areaFolder.exists)
        XCTAssertTrue(resourceFolder.exists)
        XCTAssertTrue(archiveFolder.exists)
    }

    func test_folderCard_tapNavigatesToFolderNotes() {
        // Navigate to Folders tab
        let foldersTab = app.tabBars.buttons["Folders"]
        XCTAssertTrue(foldersTab.waitForExistence(timeout: 5))
        foldersTab.tap()

        // Tap Projects folder
        let projectFolder = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Projects folder'")).firstMatch
        guard projectFolder.waitForExistence(timeout: 3) else {
            XCTFail("Projects folder not found")
            return
        }
        projectFolder.tap()

        // Should navigate to Projects view
        let folderTitle = app.navigationBars["Projects"]
        XCTAssertTrue(folderTitle.waitForExistence(timeout: 3))
    }

    func test_folderNotes_canNavigateBack() {
        // Navigate to Folders tab
        let foldersTab = app.tabBars.buttons["Folders"]
        XCTAssertTrue(foldersTab.waitForExistence(timeout: 5))
        foldersTab.tap()

        // Tap a folder
        let projectFolder = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Projects folder'")).firstMatch
        guard projectFolder.waitForExistence(timeout: 3) else { return }
        projectFolder.tap()

        // Navigate back
        let backButton = app.navigationBars.buttons["Folders"]
        if backButton.waitForExistence(timeout: 3) {
            backButton.tap()

            // Should be back on Folders
            XCTAssertTrue(app.navigationBars["Folders"].waitForExistence(timeout: 3))
        }
    }

    func test_folderNotes_emptyState_showsMessage() {
        // Navigate to Folders tab
        let foldersTab = app.tabBars.buttons["Folders"]
        XCTAssertTrue(foldersTab.waitForExistence(timeout: 5))
        foldersTab.tap()

        // Tap Archive folder (likely empty on fresh install)
        let archiveFolder = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Archive folder'")).firstMatch
        guard archiveFolder.waitForExistence(timeout: 3) else { return }
        archiveFolder.tap()

        // Empty state message should show
        let emptyMessage = app.staticTexts["No Archive"]
        XCTAssertTrue(emptyMessage.waitForExistence(timeout: 3))
    }
}
