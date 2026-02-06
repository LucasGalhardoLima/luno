import Foundation
import os

// MARK: - Luno Logger

// Structured logging using os.Logger subsystem
// Constitution: Consistent, filterable logging across all services

enum LunoLogger {
    // MARK: - Subsystem

    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.luno.app"

    // MARK: - Category Loggers

    /// Speech recognition service logging
    static let speech = Logger(subsystem: subsystem, category: "Speech")

    /// Categorization service logging (orchestrator + on-device + cloud)
    static let categorization = Logger(subsystem: subsystem, category: "Categorization")

    /// Note persistence (repository) logging
    static let repository = Logger(subsystem: subsystem, category: "Repository")

    /// UI and ViewModel logging
    static let ui = Logger(subsystem: subsystem, category: "UI")

    /// Network and API logging
    static let network = Logger(subsystem: subsystem, category: "Network")

    /// Sync (iCloud) logging
    static let sync = Logger(subsystem: subsystem, category: "Sync")
}
