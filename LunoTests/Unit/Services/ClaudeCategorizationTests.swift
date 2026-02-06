@testable import Luno
import XCTest

/// Unit tests for ClaudeCategorizationService
/// TDD: Tests for Claude API-based cloud categorization
final class ClaudeCategorizationTests: XCTestCase {
    // MARK: - Properties

    var sut: ClaudeCategorizationService!

    // MARK: - Setup

    override func setUp() async throws {
        try await super.setUp()
        // Use empty API key for unit tests - mock network layer
        sut = ClaudeCategorizationService(config: CategorizationConfig(claudeApiKey: ""))
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Availability Tests

    func test_checkAvailability_withoutApiKey_returnsUnavailable() async {
        // When
        let availability = await sut.checkAvailability()

        // Then
        if case let .unavailable(reason) = availability {
            XCTAssertEqual(reason, .noApiKey)
        } else {
            XCTFail("Should be unavailable without API key")
        }
    }

    func test_isAvailable_withoutApiKey_returnsFalse() async {
        // When
        let available = await sut.isAvailable

        // Then
        XCTAssertFalse(available)
    }

    func test_checkAvailability_withApiKey_returnsAvailable() async {
        // Given
        let configuredService = ClaudeCategorizationService(
            config: CategorizationConfig(claudeApiKey: "test-key-123")
        )

        // When
        let availability = await configuredService.checkAvailability()

        // Then
        if case .available = availability {
            // Expected
        } else {
            XCTFail("Should be available with API key configured")
        }
    }

    // MARK: - Categorization Error Tests

    func test_categorize_withoutApiKey_throwsServiceUnavailable() async {
        // Given
        let content = "Test note content"

        // When/Then
        do {
            _ = try await sut.categorize(content)
            XCTFail("Should throw serviceUnavailable error")
        } catch let error as CategorizationError {
            if case let .serviceUnavailable(reason) = error {
                XCTAssertEqual(reason, .noApiKey)
            } else {
                XCTFail("Expected serviceUnavailable error, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_categorize_emptyContent_throwsInvalidContent() async {
        // Given
        let service = ClaudeCategorizationService(
            config: CategorizationConfig(claudeApiKey: "test-key")
        )

        // When/Then
        do {
            _ = try await service.categorize("")
            XCTFail("Should throw invalidContent error")
        } catch let error as CategorizationError {
            if case .invalidContent = error {
                // Expected
            } else {
                XCTFail("Expected invalidContent error, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Prompt Building Tests

    func test_buildPrompt_includesContent() {
        // Given
        let content = "Important meeting notes about Q4 planning"

        // When
        let prompt = sut.buildCategorizationPrompt(for: content)

        // Then
        XCTAssertTrue(prompt.contains(content), "Prompt should include the note content")
    }

    func test_buildPrompt_includesPARACategories() {
        // Given
        let content = "Test note"

        // When
        let prompt = sut.buildCategorizationPrompt(for: content)

        // Then
        XCTAssertTrue(prompt.contains("project"), "Prompt should mention project category")
        XCTAssertTrue(prompt.contains("area"), "Prompt should mention area category")
        XCTAssertTrue(prompt.contains("resource"), "Prompt should mention resource category")
        XCTAssertTrue(prompt.contains("archive"), "Prompt should mention archive category")
    }

    func test_buildPrompt_requestsJSON() {
        // Given
        let content = "Test note"

        // When
        let prompt = sut.buildCategorizationPrompt(for: content)

        // Then
        XCTAssertTrue(
            prompt.lowercased().contains("json"),
            "Prompt should request JSON response format"
        )
    }

    // MARK: - Response Parsing Tests

    func test_parseResponse_validJSON_returnsResult() throws {
        // Given
        let json = """
        {
            "category": "project",
            "reasoning": "This note contains a deadline and specific deliverables.",
            "confidence": 0.92
        }
        """

        // When
        let result = try sut.parseCategorizationResponse(json)

        // Then
        XCTAssertEqual(result.category, .project)
        XCTAssertEqual(result.reasoning, "This note contains a deadline and specific deliverables.")
        XCTAssertEqual(result.confidence, 0.92, accuracy: 0.001)
    }

    func test_parseResponse_areaCategory_returnsArea() throws {
        // Given
        let json = """
        {
            "category": "area",
            "reasoning": "Ongoing responsibility without a specific end date.",
            "confidence": 0.85
        }
        """

        // When
        let result = try sut.parseCategorizationResponse(json)

        // Then
        XCTAssertEqual(result.category, .area)
    }

    func test_parseResponse_invalidJSON_throws() {
        // Given
        let invalidJSON = "not valid json"

        // When/Then
        XCTAssertThrowsError(try sut.parseCategorizationResponse(invalidJSON))
    }

    func test_parseResponse_missingCategory_throws() {
        // Given
        let json = """
        {
            "reasoning": "Some reasoning",
            "confidence": 0.5
        }
        """

        // When/Then
        XCTAssertThrowsError(try sut.parseCategorizationResponse(json))
    }

    func test_parseResponse_invalidCategory_defaultsToUncategorized() throws {
        // Given
        let json = """
        {
            "category": "invalid_category",
            "reasoning": "Unknown category type.",
            "confidence": 0.3
        }
        """

        // When
        let result = try sut.parseCategorizationResponse(json)

        // Then
        XCTAssertEqual(result.category, .uncategorized)
    }

    func test_parseResponse_confidenceClampedToRange() throws {
        // Given - confidence over 1.0
        let json = """
        {
            "category": "project",
            "reasoning": "Very confident.",
            "confidence": 1.5
        }
        """

        // When
        let result = try sut.parseCategorizationResponse(json)

        // Then
        XCTAssertLessThanOrEqual(result.confidence, 1.0)
    }
}
