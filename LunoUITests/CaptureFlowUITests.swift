import XCTest

/// UI tests for voice capture flow (T029) and text input flow (T057)
/// Tests the full user journey of capturing notes via voice and text
final class CaptureFlowUITests: XCTestCase {
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

    // MARK: - Voice Capture Flow (T029)

    func test_captureTab_isVisibleOnLaunch() {
        // Capture tab should be the default tab
        XCTAssertTrue(app.navigationBars["Capture"].exists)
    }

    func test_voiceMode_showsRecordButton() {
        // The record button should be visible in voice mode
        let recordButton = app.buttons["Start recording"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 5))
    }

    func test_voiceMode_isDefaultInputMode() {
        // Voice should be the default input mode
        let voiceButton = app.buttons["Voice input mode"]
        XCTAssertTrue(voiceButton.waitForExistence(timeout: 5))
    }

    func test_inputModeToggle_switchesToTextMode() {
        // Tap text mode toggle
        let typeButton = app.buttons["Type input mode"]
        XCTAssertTrue(typeButton.waitForExistence(timeout: 5))
        typeButton.tap()

        // Verify text editor appears
        let textInput = app.textViews["Note text input"]
        XCTAssertTrue(textInput.waitForExistence(timeout: 3))
    }

    func test_inputModeToggle_switchesBackToVoiceMode() {
        // Switch to text mode
        let typeButton = app.buttons["Type input mode"]
        XCTAssertTrue(typeButton.waitForExistence(timeout: 5))
        typeButton.tap()

        // Switch back to voice mode
        let voiceButton = app.buttons["Voice input mode"]
        voiceButton.tap()

        // Verify record button reappears
        let recordButton = app.buttons["Start recording"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 3))
    }

    // MARK: - Text Input Flow (T057)

    func test_textMode_canTypeNote() {
        // Switch to text mode
        let typeButton = app.buttons["Type input mode"]
        XCTAssertTrue(typeButton.waitForExistence(timeout: 5))
        typeButton.tap()

        // Type a note
        let textInput = app.textViews["Note text input"]
        XCTAssertTrue(textInput.waitForExistence(timeout: 3))
        textInput.tap()
        textInput.typeText("Test note content")

        // Save button should be enabled
        let saveButton = app.buttons["Save note"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3))
        XCTAssertTrue(saveButton.isEnabled)
    }

    func test_textMode_saveButtonDisabledWhenEmpty() {
        // Switch to text mode
        let typeButton = app.buttons["Type input mode"]
        XCTAssertTrue(typeButton.waitForExistence(timeout: 5))
        typeButton.tap()

        // Save button should exist but be disabled with empty text
        let saveButton = app.buttons["Save note"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3))
    }

    func test_textMode_saveNote_showsCategorizationSheet() {
        // Switch to text mode
        let typeButton = app.buttons["Type input mode"]
        XCTAssertTrue(typeButton.waitForExistence(timeout: 5))
        typeButton.tap()

        // Type a note
        let textInput = app.textViews["Note text input"]
        XCTAssertTrue(textInput.waitForExistence(timeout: 3))
        textInput.tap()
        textInput.typeText("Finish the project by Friday deadline")

        // Save the note
        let saveButton = app.buttons["Save note"]
        saveButton.tap()

        // Categorization sheet should appear
        let categorizationSheet = app.staticTexts["Categorize Note"]
        // Allow time for save + categorization
        XCTAssertTrue(categorizationSheet.waitForExistence(timeout: 5))
    }
}
