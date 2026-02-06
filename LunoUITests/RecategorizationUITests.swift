import XCTest

/// UI tests for re-categorization flow (T082)
/// Tests changing a note's category from the detail view
final class RecategorizationUITests: XCTestCase {
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

    // MARK: - Category Change from Detail View

    func test_noteDetail_showsCategorySection() {
        // Create a note first
        createAndSaveTextNote("Test note for recategorization")

        // Navigate to the note detail
        navigateToNoteDetail("Test note for recategorization")

        // Category section should be visible
        let categoryButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Category'")).firstMatch
        XCTAssertTrue(categoryButton.waitForExistence(timeout: 3))
    }

    func test_noteDetail_tapCategory_opensPicker() {
        // Create a note
        createAndSaveTextNote("Another test note for category change")

        // Navigate to note detail
        navigateToNoteDetail("Another test note for category change")

        // Tap category section
        let categoryButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Category'")).firstMatch
        guard categoryButton.waitForExistence(timeout: 3) else {
            XCTFail("Category button not found")
            return
        }
        categoryButton.tap()

        // Category picker should appear
        let pickerTitle = app.navigationBars["Change Category"]
        XCTAssertTrue(pickerTitle.waitForExistence(timeout: 3))
    }

    func test_noteDetail_toolbarMenu_hasChangeCategoryOption() {
        // Create a note
        createAndSaveTextNote("Note for toolbar menu test")

        // Navigate to note detail
        navigateToNoteDetail("Note for toolbar menu test")

        // Tap toolbar menu
        let menuButton = app.buttons["Note actions"]
        guard menuButton.waitForExistence(timeout: 3) else {
            XCTFail("Menu button not found")
            return
        }
        menuButton.tap()

        // Change Category option should exist
        let changeCategoryButton = app.buttons["Change Category"]
        XCTAssertTrue(changeCategoryButton.waitForExistence(timeout: 3))
    }

    func test_categoryPicker_showsAllCategories() {
        // Create a note
        createAndSaveTextNote("Note to test picker categories")

        // Navigate to detail and open category picker
        navigateToNoteDetail("Note to test picker categories")

        let categoryButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Category'")).firstMatch
        guard categoryButton.waitForExistence(timeout: 3) else { return }
        categoryButton.tap()

        // Wait for picker
        let pickerTitle = app.navigationBars["Change Category"]
        guard pickerTitle.waitForExistence(timeout: 3) else { return }

        // All categories should be listed
        XCTAssertTrue(app.staticTexts["Projects"].exists)
        XCTAssertTrue(app.staticTexts["Areas"].exists)
        XCTAssertTrue(app.staticTexts["Resources"].exists)
        XCTAssertTrue(app.staticTexts["Archive"].exists)
        XCTAssertTrue(app.staticTexts["Uncategorized"].exists)
    }

    func test_categoryPicker_cancelDismisses() {
        // Create a note
        createAndSaveTextNote("Note to test cancel")

        // Navigate to detail and open picker
        navigateToNoteDetail("Note to test cancel")

        let categoryButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Category'")).firstMatch
        guard categoryButton.waitForExistence(timeout: 3) else { return }
        categoryButton.tap()

        // Cancel
        let cancelButton = app.buttons["Cancel"]
        guard cancelButton.waitForExistence(timeout: 3) else { return }
        cancelButton.tap()

        // Should be back on detail view
        let detailTitle = app.navigationBars["Note"]
        XCTAssertTrue(detailTitle.waitForExistence(timeout: 3))
    }

    // MARK: - Helpers

    private func createAndSaveTextNote(_ content: String) {
        // Ensure on Capture tab
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

        // Dismiss categorization sheet
        let skipButton = app.buttons["Skip"]
        if skipButton.waitForExistence(timeout: 5) {
            skipButton.tap()
        }
    }

    private func navigateToNoteDetail(_ content: String) {
        // Navigate to Notes tab
        let notesTab = app.tabBars.buttons["Notes"]
        guard notesTab.waitForExistence(timeout: 3) else { return }
        notesTab.tap()

        // Find and tap the note
        let noteText = app.staticTexts[content]
        if noteText.waitForExistence(timeout: 5) {
            noteText.tap()
        }
    }
}
