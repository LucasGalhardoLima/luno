import SwiftUI

// MARK: - Settings View

// App settings for API configuration and sync preferences
// Constitution: Clean, accessible settings interface

struct SettingsView: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SettingsViewModel()

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                // API Configuration
                apiSection

                // Categorization
                categorizationSection

                // Sync
                syncSection

                // About
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(LunoColors.primary)
                }
            }
        }
    }

    // MARK: - API Section

    private var apiSection: some View {
        Section {
            // API Key input
            VStack(alignment: .leading, spacing: LunoTheme.Spacing.xs) {
                HStack {
                    Text("API Key")
                        .font(LunoTheme.Typography.body)

                    Spacer()

                    if !viewModel.claudeApiKey.isEmpty {
                        apiKeyStatusBadge
                    }
                }

                HStack {
                    if viewModel.isApiKeyVisible {
                        TextField("sk-ant-...", text: $viewModel.claudeApiKey)
                            .font(LunoTheme.Typography.footnote)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    } else {
                        Text(viewModel.claudeApiKey.isEmpty ? "Not configured" : viewModel.maskedApiKey)
                            .font(LunoTheme.Typography.footnote)
                            .foregroundStyle(viewModel.claudeApiKey.isEmpty ? LunoColors.textSecondary : LunoColors.textPrimary)
                    }

                    Spacer()

                    Button {
                        viewModel.isApiKeyVisible.toggle()
                    } label: {
                        Image(systemName: viewModel.isApiKeyVisible ? "eye.slash" : "eye")
                            .font(LunoTheme.Typography.body)
                            .foregroundStyle(LunoColors.textSecondary)
                    }
                    .accessibilityLabel(viewModel.isApiKeyVisible ? "Hide API key" : "Show API key")
                }
            }

            if !viewModel.claudeApiKey.isEmpty {
                Button("Clear API Key", role: .destructive) {
                    viewModel.clearApiKey()
                }
            }

            // Model selection
            Picker("Model", selection: $viewModel.claudeModel) {
                Text("Claude Sonnet 4.5").tag("claude-sonnet-4-5-20250929")
                Text("Claude Haiku 4.5").tag("claude-haiku-4-5-20251001")
            }
        } header: {
            Label("Claude API", systemImage: "cloud")
        } footer: {
            Text("An API key is required for cloud-based AI categorization. Get one from console.anthropic.com.")
        }
    }

    // MARK: - API Key Status Badge

    private var apiKeyStatusBadge: some View {
        HStack(spacing: LunoTheme.Spacing.xxs) {
            Image(systemName: viewModel.isApiKeyValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(LunoTheme.Typography.caption2)
            Text(viewModel.isApiKeyValid ? "Valid" : "Invalid format")
                .font(LunoTheme.Typography.caption2)
        }
        .foregroundStyle(viewModel.isApiKeyValid ? LunoColors.State.success : LunoColors.State.warning)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("API key status: \(viewModel.isApiKeyValid ? "valid" : "invalid format")")
    }

    // MARK: - Categorization Section

    private var categorizationSection: some View {
        Section {
            VStack(alignment: .leading, spacing: LunoTheme.Spacing.xs) {
                HStack {
                    Text("Confidence Threshold")
                        .font(LunoTheme.Typography.body)

                    Spacer()

                    Text("\(Int(viewModel.confidenceThreshold * 100))%")
                        .font(LunoTheme.Typography.body)
                        .fontWeight(.medium)
                        .foregroundStyle(LunoColors.primary)
                }

                Slider(value: $viewModel.confidenceThreshold, in: 0.5 ... 1.0, step: 0.05)
                    .tint(LunoColors.primary)
                    .accessibilityLabel("Confidence threshold")
                    .accessibilityValue("\(Int(viewModel.confidenceThreshold * 100)) percent")
            }
        } header: {
            Label("AI Categorization", systemImage: "cpu")
        } footer: {
            Text("Notes categorized below this confidence level will use cloud AI as a fallback.")
        }
    }

    // MARK: - Sync Section

    private var syncSection: some View {
        Section {
            Toggle(isOn: $viewModel.iCloudSyncEnabled) {
                HStack(spacing: LunoTheme.Spacing.sm) {
                    Image(systemName: "icloud")
                        .foregroundStyle(LunoColors.primary)
                    Text("iCloud Sync")
                }
            }
            .tint(LunoColors.primary)
            .accessibilityLabel("iCloud sync")
            .accessibilityValue(viewModel.iCloudSyncEnabled ? "Enabled" : "Disabled")
        } header: {
            Label("Sync", systemImage: "arrow.triangle.2.circlepath")
        } footer: {
            Text(viewModel.iCloudSyncEnabled
                ? "Notes will sync across your Apple devices via iCloud."
                : "Notes are stored locally on this device only.")
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text("\(viewModel.appVersion) (\(viewModel.buildNumber))")
                    .foregroundStyle(LunoColors.textSecondary)
            }
        } header: {
            Label("About", systemImage: "info.circle")
        }
    }
}

// MARK: - Preview

#Preview("Settings") {
    SettingsView()
}
