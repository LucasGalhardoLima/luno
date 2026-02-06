@testable import Luno
import XCTest

/// Unit tests for OnDeviceCategorizationService
/// TDD: Tests for Foundation Models-based on-device categorization
final class OnDeviceCategorizationTests: XCTestCase {
    // MARK: - Properties

    var sut: OnDeviceCategorizationService!

    // MARK: - Setup

    override func setUp() async throws {
        try await super.setUp()
        sut = OnDeviceCategorizationService()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Availability Tests

    func test_checkAvailability_returnsValidResult() async {
        // When
        let availability = await sut.checkAvailability()

        // Then - Should be available or have a specific reason
        switch availability {
        case .available:
            break // Valid
        case let .unavailable(reason):
            // On non-supported devices, should have a reason
            XCTAssertFalse(reason.rawValue.isEmpty)
        }
    }

    // MARK: - Categorization Tests

    func test_categorize_projectContent_returnsProject() async throws {
        // Skip if not available on this device
        let availability = await sut.checkAvailability()
        guard case .available = availability else {
            throw XCTSkip("On-device categorization not available on this device")
        }

        // Given
        let content = "Finish the landing page redesign by Friday. Need to coordinate with the design team and deploy to staging."

        // When
        let result = try await sut.categorize(content)

        // Then
        XCTAssertEqual(result.category, .project)
        XCTAssertGreaterThan(result.confidence, 0)
        XCTAssertFalse(result.reasoning.isEmpty)
    }

    func test_categorize_areaContent_returnsArea() async throws {
        let availability = await sut.checkAvailability()
        guard case .available = availability else {
            throw XCTSkip("On-device categorization not available on this device")
        }

        // Given
        let content = "Weekly review of health metrics and exercise routine. Maintain consistent sleep schedule and hydration levels."

        // When
        let result = try await sut.categorize(content)

        // Then
        XCTAssertEqual(result.category, .area)
        XCTAssertGreaterThan(result.confidence, 0)
    }

    func test_categorize_resourceContent_returnsResource() async throws {
        let availability = await sut.checkAvailability()
        guard case .available = availability else {
            throw XCTSkip("On-device categorization not available on this device")
        }

        // Given
        let content = "Great article about SwiftUI performance optimization. Key takeaway: use lazy stacks and avoid unnecessary state changes."

        // When
        let result = try await sut.categorize(content)

        // Then
        XCTAssertEqual(result.category, .resource)
        XCTAssertGreaterThan(result.confidence, 0)
    }

    func test_categorize_archiveContent_returnsArchive() async throws {
        let availability = await sut.checkAvailability()
        guard case .available = availability else {
            throw XCTSkip("On-device categorization not available on this device")
        }

        // Given
        let content = "Completed the Q3 marketing campaign. Final metrics: 15% increase in engagement. Campaign wrapped up successfully."

        // When
        let result = try await sut.categorize(content)

        // Then
        XCTAssertEqual(result.category, .archive)
        XCTAssertGreaterThan(result.confidence, 0)
    }

    func test_categorize_emptyContent_throwsInvalidContent() async {
        // Given
        let content = ""

        // When/Then
        do {
            _ = try await sut.categorize(content)
            XCTFail("Should throw invalidContent error")
        } catch let error as CategorizationError {
            if case .invalidContent = error {
                // Expected
            } else {
                XCTFail("Expected invalidContent error, got \(error)")
            }
        } catch {
            // May also throw serviceUnavailable on unsupported devices
        }
    }

    func test_categorize_resultConfidence_isInValidRange() async throws {
        let availability = await sut.checkAvailability()
        guard case .available = availability else {
            throw XCTSkip("On-device categorization not available on this device")
        }

        // Given
        let content = "Review the budget for next quarter"

        // When
        let result = try await sut.categorize(content)

        // Then
        XCTAssertGreaterThanOrEqual(result.confidence, 0.0)
        XCTAssertLessThanOrEqual(result.confidence, 1.0)
    }

    func test_categorize_resultReasoning_isNotEmpty() async throws {
        let availability = await sut.checkAvailability()
        guard case .available = availability else {
            throw XCTSkip("On-device categorization not available on this device")
        }

        // Given
        let content = "Plan the team offsite for next month"

        // When
        let result = try await sut.categorize(content)

        // Then
        XCTAssertFalse(result.reasoning.isEmpty, "Reasoning should explain the categorization")
    }
}
