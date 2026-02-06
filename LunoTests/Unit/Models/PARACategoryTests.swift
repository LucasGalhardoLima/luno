@testable import Luno
import XCTest

/// Unit tests for PARACategory enum
/// TDD: These tests must fail before implementation
final class PARACategoryTests: XCTestCase {
    // MARK: - Basic Cases

    func test_allCases_containsFourMainCategories() {
        // Given
        let mainCategories: [PARACategory] = [.project, .area, .resource, .archive]

        // Then
        for category in mainCategories {
            XCTAssertTrue(PARACategory.allCases.contains(category))
        }
    }

    func test_allCases_containsUncategorized() {
        XCTAssertTrue(PARACategory.allCases.contains(.uncategorized))
    }

    func test_paraCategories_excludesUncategorized() {
        // Given
        let paraCategories = PARACategory.paraCategories

        // Then
        XCTAssertFalse(paraCategories.contains(.uncategorized))
        XCTAssertEqual(paraCategories.count, 4)
    }

    // MARK: - Display Names

    func test_displayName_project_returnsProjects() {
        XCTAssertEqual(PARACategory.project.displayName, "Projects")
    }

    func test_displayName_area_returnsAreas() {
        XCTAssertEqual(PARACategory.area.displayName, "Areas")
    }

    func test_displayName_resource_returnsResources() {
        XCTAssertEqual(PARACategory.resource.displayName, "Resources")
    }

    func test_displayName_archive_returnsArchive() {
        XCTAssertEqual(PARACategory.archive.displayName, "Archive")
    }

    func test_displayName_uncategorized_returnsUncategorized() {
        XCTAssertEqual(PARACategory.uncategorized.displayName, "Uncategorized")
    }

    // MARK: - Descriptions

    func test_description_project_containsDeadline() {
        let description = PARACategory.project.description
        XCTAssertTrue(description.lowercased().contains("deadline"))
    }

    func test_description_area_containsOngoing() {
        let description = PARACategory.area.description
        XCTAssertTrue(description.lowercased().contains("ongoing"))
    }

    func test_description_resource_containsReference() {
        let description = PARACategory.resource.description
        XCTAssertTrue(description.lowercased().contains("reference"))
    }

    func test_description_archive_containsCompleted() {
        let description = PARACategory.archive.description
        XCTAssertTrue(description.lowercased().contains("completed") || description.lowercased().contains("inactive"))
    }

    // MARK: - Icon Names

    func test_iconName_returnsValidSFSymbol() {
        for category in PARACategory.allCases {
            let iconName = category.iconName
            XCTAssertFalse(iconName.isEmpty, "Icon name for \(category) should not be empty")
            // All should use SF Symbols (contain common suffixes)
            XCTAssertTrue(
                iconName.contains(".fill") || iconName.contains("folder") ||
                    iconName.contains("rectangle") || iconName.contains("book") ||
                    iconName.contains("archivebox") || iconName.contains("questionmark"),
                "Icon \(iconName) should be a valid SF Symbol"
            )
        }
    }

    // MARK: - Codable

    func test_encode_decode_roundTrip() throws {
        // Given
        let original = PARACategory.project

        // When
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PARACategory.self, from: encoded)

        // Then
        XCTAssertEqual(original, decoded)
    }

    func test_allCategories_encodeDecodeRoundTrip() throws {
        for category in PARACategory.allCases {
            let encoded = try JSONEncoder().encode(category)
            let decoded = try JSONDecoder().decode(PARACategory.self, from: encoded)
            XCTAssertEqual(category, decoded)
        }
    }

    // MARK: - Raw Values

    func test_rawValue_project() {
        XCTAssertEqual(PARACategory.project.rawValue, "project")
    }

    func test_rawValue_area() {
        XCTAssertEqual(PARACategory.area.rawValue, "area")
    }

    func test_rawValue_resource() {
        XCTAssertEqual(PARACategory.resource.rawValue, "resource")
    }

    func test_rawValue_archive() {
        XCTAssertEqual(PARACategory.archive.rawValue, "archive")
    }

    func test_rawValue_uncategorized() {
        XCTAssertEqual(PARACategory.uncategorized.rawValue, "uncategorized")
    }

    func test_initFromRawValue_validValue() {
        XCTAssertEqual(PARACategory(rawValue: "project"), .project)
        XCTAssertEqual(PARACategory(rawValue: "area"), .area)
        XCTAssertEqual(PARACategory(rawValue: "resource"), .resource)
        XCTAssertEqual(PARACategory(rawValue: "archive"), .archive)
        XCTAssertEqual(PARACategory(rawValue: "uncategorized"), .uncategorized)
    }

    func test_initFromRawValue_invalidValue_returnsNil() {
        XCTAssertNil(PARACategory(rawValue: "invalid"))
        XCTAssertNil(PARACategory(rawValue: ""))
        XCTAssertNil(PARACategory(rawValue: "Project")) // Case sensitive
    }
}
