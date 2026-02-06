import Foundation

// MARK: - PARA Category

// PARA method categories for note organization
// Constitution: Follow established productivity methodology
//
// The PARA method organizes information into four categories:
// - Projects: Short-term efforts with deadlines
// - Areas: Long-term responsibilities to maintain
// - Resources: Topics of ongoing interest
// - Archive: Inactive items from the other categories

enum PARACategory: String, Codable, CaseIterable, Sendable {
    case project
    case area
    case resource
    case archive
    case uncategorized

    // MARK: - Display Properties

    /// Human-readable display name (plural form for UI)
    var displayName: String {
        switch self {
        case .project:
            "Projects"
        case .area:
            "Areas"
        case .resource:
            "Resources"
        case .archive:
            "Archive"
        case .uncategorized:
            "Uncategorized"
        }
    }

    /// Description explaining the category's purpose
    var description: String {
        switch self {
        case .project:
            "Short-term efforts with a deadline and specific outcome"
        case .area:
            "Ongoing responsibilities that require maintenance"
        case .resource:
            "Reference materials and topics of interest"
        case .archive:
            "Completed or inactive items"
        case .uncategorized:
            "Notes pending categorization"
        }
    }

    /// SF Symbol icon name for the category
    var iconName: String {
        switch self {
        case .project:
            "folder.fill"
        case .area:
            "rectangle.stack.fill"
        case .resource:
            "book.fill"
        case .archive:
            "archivebox.fill"
        case .uncategorized:
            "questionmark.folder.fill"
        }
    }

    // MARK: - Static Properties

    /// Returns only the four main PARA categories (excludes uncategorized)
    static var paraCategories: [PARACategory] {
        [.project, .area, .resource, .archive]
    }
}
