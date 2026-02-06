import Foundation

// MARK: - Date Formatting Extensions

// Date formatting utilities for consistent display
// Constitution: User-friendly date presentation

extension Date {
    // MARK: - Relative Formatting

    /// Returns a relative time string (e.g., "2 hours ago", "Yesterday")
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Returns a short relative time string (e.g., "2h ago", "1d ago")
    var shortRelativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    // MARK: - Absolute Formatting

    /// Returns formatted date string (e.g., "Jan 15, 2024")
    var dateFormatted: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    /// Returns formatted time string (e.g., "2:30 PM")
    var timeFormatted: String {
        formatted(date: .omitted, time: .shortened)
    }

    /// Returns formatted date and time string (e.g., "Jan 15, 2024 at 2:30 PM")
    var dateTimeFormatted: String {
        formatted(date: .abbreviated, time: .shortened)
    }

    // MARK: - Smart Formatting

    /// Returns a smart formatted string based on how recent the date is
    /// - Today: shows time only (e.g., "2:30 PM")
    /// - Yesterday: shows "Yesterday at 2:30 PM"
    /// - This week: shows day name (e.g., "Monday at 2:30 PM")
    /// - Older: shows full date (e.g., "Jan 15, 2024")
    var smartFormatted: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(self) {
            return timeFormatted
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday at \(timeFormatted)"
        } else if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now),
                  self > weekAgo {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            return "\(dayFormatter.string(from: self)) at \(timeFormatted)"
        } else if calendar.isDate(self, equalTo: now, toGranularity: .year) {
            // Same year, show month and day
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: self)
        } else {
            return dateFormatted
        }
    }

    // MARK: - Grouping Helpers

    /// Returns a section header string for grouping notes
    /// - Today: "Today"
    /// - Yesterday: "Yesterday"
    /// - This week: day name
    /// - This month: "Earlier this month"
    /// - Older: month name
    var sectionHeader: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now),
                  self > weekAgo {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            return dayFormatter.string(from: self)
        } else if calendar.isDate(self, equalTo: now, toGranularity: .month) {
            return "Earlier this month"
        } else if calendar.isDate(self, equalTo: now, toGranularity: .year) {
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMMM"
            return monthFormatter.string(from: self)
        } else {
            let yearMonthFormatter = DateFormatter()
            yearMonthFormatter.dateFormat = "MMMM yyyy"
            return yearMonthFormatter.string(from: self)
        }
    }
}
