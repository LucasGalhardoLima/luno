// MARK: - SyncServiceProtocol
// Contract for iCloud sync management

import Foundation
import Combine

/// Protocol defining iCloud sync operations
/// Implementations: SyncService (CloudKit)
protocol SyncServiceProtocol {

    // MARK: - State

    /// Current sync status
    var syncStatus: SyncStatus { get }

    /// Publisher for sync status changes
    var syncStatusPublisher: AnyPublisher<SyncStatus, Never> { get }

    /// Whether sync is enabled by user
    var isSyncEnabled: Bool { get }

    // MARK: - Configuration

    /// Enables or disables iCloud sync
    /// Note: May require app restart to take effect
    /// - Parameter enabled: Whether to enable sync
    /// - Throws: SyncError if configuration fails
    func setSyncEnabled(_ enabled: Bool) async throws

    // MARK: - iCloud Account

    /// Checks iCloud account availability
    /// - Returns: Account status
    func checkAccountStatus() async -> iCloudAccountStatus

    // MARK: - Sync Operations

    /// Triggers immediate sync (if enabled)
    /// - Throws: SyncError if sync fails
    func syncNow() async throws

    /// Gets last sync timestamp
    var lastSyncDate: Date? { get }
}

// MARK: - Supporting Types

enum SyncStatus: Equatable {
    case disabled           // User has sync turned off
    case idle               // Sync enabled, nothing to sync
    case syncing            // Currently syncing
    case synced(Date)       // Last successful sync
    case error(SyncErrorType)
    case accountUnavailable // No iCloud account

    var displayText: String {
        switch self {
        case .disabled:
            return "iCloud sync disabled"
        case .idle:
            return "Up to date"
        case .syncing:
            return "Syncing..."
        case .synced(let date):
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            return "Synced \(formatter.localizedString(for: date, relativeTo: Date()))"
        case .error(let type):
            return "Sync error: \(type.displayText)"
        case .accountUnavailable:
            return "Sign in to iCloud to sync"
        }
    }
}

enum SyncErrorType: Equatable {
    case networkUnavailable
    case quotaExceeded
    case serverError
    case conflict
    case unknown

    var displayText: String {
        switch self {
        case .networkUnavailable: return "No internet connection"
        case .quotaExceeded: return "iCloud storage full"
        case .serverError: return "iCloud temporarily unavailable"
        case .conflict: return "Sync conflict detected"
        case .unknown: return "Unknown error"
        }
    }
}

enum iCloudAccountStatus {
    case available
    case noAccount
    case restricted
    case temporarilyUnavailable
    case unknown
}

enum SyncError: Error, LocalizedError {
    case notEnabled
    case accountUnavailable
    case networkUnavailable
    case quotaExceeded
    case serverError(underlying: Error)
    case configurationFailed(reason: String)

    var errorDescription: String? {
        switch self {
        case .notEnabled:
            return "iCloud sync is not enabled"
        case .accountUnavailable:
            return "iCloud account not available"
        case .networkUnavailable:
            return "Network connection unavailable"
        case .quotaExceeded:
            return "iCloud storage quota exceeded"
        case .serverError(let error):
            return "Server error: \(error.localizedDescription)"
        case .configurationFailed(let reason):
            return "Configuration failed: \(reason)"
        }
    }
}
