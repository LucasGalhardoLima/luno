import XCTest

/// UI tests for categorization confirmation flow (T044)
/// Tests the user journey of categorizing notes after saving
final class CategorizationUITests: XCTestCase {
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

    // MARK: - Categorization Sheet

    func test_categorizationSheet_appearsAfterSave() {
        // Navigate to text mode and save a note
        saveTextNote("Meeting notes about project timeline and deadlines")

        // Categorization sheet should appear
        let sheetTitle = app.staticTexts["Categorize Note"]
        XCTAssertTrue(sheetTitle.waitForExistence(timeout: 5))
    }

    func test_categorizationSheet_showsPARACategories() {
        // Save a note to trigger categorization
        saveTextNote("Weekly health check-in and fitness progress")

        // Wait for sheet
        let sheetTitle = app.staticTexts["Categorize Note"]
        guard sheetTitle.waitForExistence(timeout: 5) else {
            XCTFail("Categorization sheet did not appear")
            return
        }

        // Verify PARA categories are shown
        XCTAssertTrue(app.staticTexts["Projects"].exists)
        XCTAssertTrue(app.staticTexts["Areas"].exists)
        XCTAssertTrue(app.staticTexts["Resources"].exists)
        XCTAssertTrue(app.staticTexts["Archive"].exists)
    }

    func test_categorizationSheet_canSelectCategory() {
        // Save a note
        saveTextNote("Interesting article about machine learning techniques")

        // Wait for sheet
        let sheetTitle = app.staticTexts["Categorize Note"]
        guard sheetTitle.waitForExistence(timeout: 5) else {
            XCTFail("Categorization sheet did not appear")
            return
        }

        // Select a category
        let resourceButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Resources'")).firstMatch
        if resourceButton.waitForExistence(timeout: 3) {
            resourceButton.tap()
        }
    }

    func test_categorizationSheet_canSkip() {
        // Save a note
        saveTextNote("Quick thought about something")

        // Wait for sheet
        let sheetTitle = app.staticTexts["Categorize Note"]
        guard sheetTitle.waitForExistence(timeout: 5) else {
            XCTFail("Categorization sheet did not appear")
            return
        }

        // Tap Skip button
        let skipButton = app.buttons["Skip"]
        if skipButton.waitForExistence(timeout: 3) {
            skipButton.tap()
        }
    }

    // MARK: - Helpers

    private func saveTextNote(_ content: String) {
        // Switch to text mode
        let typeButton = app.buttons["Type input mode"]
        guard typeButton.waitForExistence(timeout: 5) else { return }
        typeButton.tap()

        // Type the note
        let textInput = app.textViews["Note text input"]
        guard textInput.waitForExistence(timeout: 3) else { return }
        textInput.tap()
        textInput.typeText(content)

        // Save
        let saveButton = app.buttons["Save note"]
        saveButton.tap()
    }
}
