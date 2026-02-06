import Foundation
import os
import SwiftUI

// MARK: - Settings View Model

// ViewModel for app settings management
// Constitution: MVVM with @Observable

@MainActor
@Observable
final class SettingsViewModel {
    // MARK: - API Configuration

    /// Claude API key for cloud categorization
    var claudeApiKey: String {
        didSet { saveApiKey(claudeApiKey) }
    }

    /// Claude model selection
    var claudeModel: String {
        didSet { UserDefaults.standard.set(claudeModel, forKey: Keys.claudeModel) }
    }

    /// Confidence threshold for on-device categorization (0.0 - 1.0)
    var confidenceThreshold: Double {
        didSet { UserDefaults.standard.set(confidenceThreshold, forKey: Keys.confidenceThreshold) }
    }

    // MARK: - Sync Settings

    /// Whether iCloud sync is enabled
    var iCloudSyncEnabled: Bool {
        didSet { UserDefaults.standard.set(iCloudSyncEnabled, forKey: Keys.iCloudSync) }
    }

    // MARK: - Display

    /// Whether API key is visible (masked by default)
    var isApiKeyVisible: Bool = false

    /// Masked version of the API key
    var maskedApiKey: String {
        guard !claudeApiKey.isEmpty else { return "" }
        let prefix = String(claudeApiKey.prefix(8))
        let suffix = String(claudeApiKey.suffix(4))
        return "\(prefix)...\(suffix)"
    }

    /// Whether the API key appears valid
    var isApiKeyValid: Bool {
        claudeApiKey.hasPrefix("sk-ant-") && claudeApiKey.count > 20
    }

    // MARK: - App Info

    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    // MARK: - Private

    private let log = LunoLogger.ui

    // MARK: - Keys

    private enum Keys {
        static let claudeApiKey = "luno.claude.apiKey"
        static let claudeModel = "luno.claude.model"
        static let confidenceThreshold = "luno.categorization.confidenceThreshold"
        static let iCloudSync = "luno.sync.iCloud"
    }

    // MARK: - Initialization

    init() {
        claudeApiKey = Self.loadApiKey()
        claudeModel = UserDefaults.standard.string(forKey: Keys.claudeModel) ?? "claude-sonnet-4-20250514"
        confidenceThreshold = UserDefaults.standard.object(forKey: Keys.confidenceThreshold) as? Double ?? 0.8
        iCloudSyncEnabled = UserDefaults.standard.bool(forKey: Keys.iCloudSync)
        log.debug("Settings loaded")
    }

    // MARK: - Actions

    func clearApiKey() {
        claudeApiKey = ""
        log.info("API key cleared")
    }

    /// Build a CategorizationConfig from current settings
    func buildCategorizationConfig() -> CategorizationConfig {
        CategorizationConfig(
            confidenceThreshold: confidenceThreshold,
            storeTrainingExamples: true,
            claudeApiKey: claudeApiKey,
            claudeModel: claudeModel
        )
    }

    // MARK: - Persistence

    // Note: For production, migrate API key to Keychain for secure storage.
    // Using UserDefaults for development simplicity.

    private func saveApiKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: Keys.claudeApiKey)
    }

    private static func loadApiKey() -> String {
        UserDefaults.standard.string(forKey: Keys.claudeApiKey) ?? ""
    }
}
