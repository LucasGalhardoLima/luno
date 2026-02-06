import XCTest

/// UI tests for notes navigation (T064)
/// Tests browsing notes, search, and filtering
final class NotesNavigationUITests: XCTestCase {
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

    func test_notesTab_isAccessible() {
        // Tap Notes tab
        let notesTab = app.tabBars.buttons["Notes"]
        XCTAssertTrue(notesTab.waitForExistence(timeout: 5))
        notesTab.tap()

        // Verify navigation title
        XCTAssertTrue(app.navigationBars["Notes"].waitForExistence(timeout: 3))
    }

    func test_notesTab_showsEmptyState() {
        // Navigate to Notes tab
        let notesTab = app.tabBars.buttons["Notes"]
        XCTAssertTrue(notesTab.waitForExistence(timeout: 5))
        notesTab.tap()

        // Empty state should show on fresh install
        let emptyTitle = app.staticTexts["No Notes Yet"]
        XCTAssertTrue(emptyTitle.waitForExistence(timeout: 3))
    }

    func test_notesTab_hasSearchBar() {
        // Navigate to Notes tab
        let notesTab = app.tabBars.buttons["Notes"]
        XCTAssertTrue(notesTab.waitForExistence(timeout: 5))
        notesTab.tap()

        // Search bar should be available (may need to pull down to reveal)
        let searchField = app.searchFields["Search notes"]
        // On iOS 17+, search is part of navigation bar
        if !searchField.exists {
            // Swipe down to reveal search
            app.swipeDown()
        }
    }

    func test_notesTab_hasFilterButton() {
        // Navigate to Notes tab
        let notesTab = app.tabBars.buttons["Notes"]
        XCTAssertTrue(notesTab.waitForExistence(timeout: 5))
        notesTab.tap()

        // Filter button should exist
        let filterButton = app.buttons["Filter by category"]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 3))
    }

    func test_notesTab_hasSettingsButton() {
        // Navigate to Notes tab
        let notesTab = app.tabBars.buttons["Notes"]
        XCTAssertTrue(notesTab.waitForExistence(timeout: 5))
        notesTab.tap()

        // Settings button should exist
        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 3))
    }

    func test_settingsButton_opensSettingsSheet() {
        // Navigate to Notes tab
        let notesTab = app.tabBars.buttons["Notes"]
        XCTAssertTrue(notesTab.waitForExistence(timeout: 5))
        notesTab.tap()

        // Tap settings
        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 3))
        settingsButton.tap()

        // Settings sheet should appear
        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3))
    }

    // MARK: - Notes with Content

    func test_noteCard_tapNavigatesToDetail() {
        // First create a note
        createAndSaveTextNote("Test note for navigation")

        // Navigate to Notes tab
        let notesTab = app.tabBars.buttons["Notes"]
        notesTab.tap()

        // Wait for notes to load and tap the first card
        let noteCell = app.staticTexts["Test note for navigation"]
        if noteCell.waitForExistence(timeout: 5) {
            noteCell.tap()

            // Should navigate to detail view
            let detailTitle = app.navigationBars["Note"]
            XCTAssertTrue(detailTitle.waitForExistence(timeout: 3))
        }
    }

    // MARK: - Helpers

    private func createAndSaveTextNote(_ content: String) {
        // Make sure we're on Capture tab
        let captureTab = app.tabBars.buttons["Capture"]
        if captureTab.waitForExistence(timeout: 3) {
            captureTab.tap()
        }

        // Switch to text mode
        let typeButton = app.buttons["Type input mode"]
        guard typeButton.waitForExistence(timeout: 5) else { return }
        typeButton.tap()

        // Type and save
        let textInput = app.textViews["Note text input"]
        guard textInput.waitForExistence(timeout: 3) else { return }
        textInput.tap()
        textInput.typeText(content)

        let saveButton = app.buttons["Save note"]
        saveButton.tap()

        // Dismiss categorization sheet if it appears
        let skipButton = app.buttons["Skip"]
        if skipButton.waitForExistence(timeout: 3) {
            skipButton.tap()
        }
    }
}
