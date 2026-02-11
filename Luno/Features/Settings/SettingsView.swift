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
            ZStack {
                LunoBackgroundView()

                ScrollView {
                    VStack(spacing: LunoTheme.Spacing.lg) {
                        appearanceSection
                        apiSection
                        categorizationSection
                        syncSection
                        aboutSection
                    }
                    .padding(LunoTheme.Spacing.md)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .lunoNavChrome()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(LunoColors.brand500)
                }
            }
        }
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: LunoTheme.Spacing.sm) {
            sectionHeader(title: "Appearance", icon: "paintbrush")

            Picker("Theme", selection: $viewModel.themePreference) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .pickerStyle(.segmented)
            .padding(LunoTheme.Spacing.md)
            .lunoGlassSurface(cornerRadius: LunoTheme.CornerRadius.card, fill: LunoColors.surface1)
        }
    }

    // MARK: - API Section

    private var apiSection: some View {
        VStack(alignment: .leading, spacing: LunoTheme.Spacing.sm) {
            sectionHeader(title: "Claude API", icon: "cloud")

            VStack(alignment: .leading, spacing: LunoTheme.Spacing.sm) {
                HStack {
                    Text("API Key")
                        .font(LunoTheme.Typography.body)
                        .foregroundStyle(LunoColors.text0)
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
                            .foregroundStyle(LunoColors.text0)
                    } else {
                        Text(viewModel.claudeApiKey.isEmpty ? "Not configured" : viewModel.maskedApiKey)
                            .font(LunoTheme.Typography.footnote)
                            .foregroundStyle(viewModel.claudeApiKey.isEmpty ? LunoColors.text1 : LunoColors.text0)
                    }

                    Spacer()

                    Button {
                        viewModel.isApiKeyVisible.toggle()
                    } label: {
                        Image(systemName: viewModel.isApiKeyVisible ? "eye.slash" : "eye")
                            .font(LunoTheme.Typography.body)
                            .foregroundStyle(LunoColors.text1)
                    }
                    .accessibilityLabel(viewModel.isApiKeyVisible ? "Hide API key" : "Show API key")
                }
                .padding(LunoTheme.Spacing.sm)
                .lunoGlassSurface(cornerRadius: LunoTheme.CornerRadius.md, fill: LunoColors.surface2)

                if !viewModel.claudeApiKey.isEmpty {
                    Button("Clear API Key", role: .destructive) {
                        viewModel.clearApiKey()
                    }
                }

                Picker("Model", selection: $viewModel.claudeModel) {
                    Text("Claude Sonnet 4.5").tag("claude-sonnet-4-5-20250929")
                    Text("Claude Haiku 4.5").tag("claude-haiku-4-5-20251001")
                }
                .pickerStyle(.menu)
                .tint(LunoColors.brand500)
            }
            .padding(LunoTheme.Spacing.md)
            .lunoGlassSurface(cornerRadius: LunoTheme.CornerRadius.card, fill: LunoColors.surface1)

            Text("An API key is required for cloud-based AI categorization. Get one from console.anthropic.com.")
                .font(LunoTheme.Typography.caption)
                .foregroundStyle(LunoColors.text1)
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
        VStack(alignment: .leading, spacing: LunoTheme.Spacing.sm) {
            sectionHeader(title: "AI Categorization", icon: "cpu")

            VStack(alignment: .leading, spacing: LunoTheme.Spacing.xs) {
                HStack {
                    Text("Confidence Threshold")
                        .font(LunoTheme.Typography.body)
                        .foregroundStyle(LunoColors.text0)

                    Spacer()

                    Text("\(Int(viewModel.confidenceThreshold * 100))%")
                        .font(LunoTheme.Typography.body)
                        .fontWeight(.medium)
                        .foregroundStyle(LunoColors.brand500)
                }

                Slider(value: $viewModel.confidenceThreshold, in: 0.5 ... 1.0, step: 0.05)
                    .tint(LunoColors.brand500)
                    .accessibilityLabel("Confidence threshold")
                    .accessibilityValue("\(Int(viewModel.confidenceThreshold * 100)) percent")
            }
            .padding(LunoTheme.Spacing.md)
            .lunoGlassSurface(cornerRadius: LunoTheme.CornerRadius.card, fill: LunoColors.surface1)

            Text("Notes categorized below this confidence level will use cloud AI as a fallback.")
                .font(LunoTheme.Typography.caption)
                .foregroundStyle(LunoColors.text1)
        }
    }

    // MARK: - Sync Section

    private var syncSection: some View {
        VStack(alignment: .leading, spacing: LunoTheme.Spacing.sm) {
            sectionHeader(title: "Sync", icon: "arrow.triangle.2.circlepath")

            Toggle(isOn: $viewModel.iCloudSyncEnabled) {
                HStack(spacing: LunoTheme.Spacing.sm) {
                    Image(systemName: "icloud")
                        .foregroundStyle(LunoColors.brand500)
                    Text("iCloud Sync")
                        .foregroundStyle(LunoColors.text0)
                }
            }
            .padding(LunoTheme.Spacing.md)
            .tint(LunoColors.brand500)
            .lunoGlassSurface(cornerRadius: LunoTheme.CornerRadius.card, fill: LunoColors.surface1)
            .accessibilityLabel("iCloud sync")
            .accessibilityValue(viewModel.iCloudSyncEnabled ? "Enabled" : "Disabled")

            Text(viewModel.iCloudSyncEnabled
                ? "Notes will sync across your Apple devices via iCloud."
                : "Notes are stored locally on this device only.")
                .font(LunoTheme.Typography.caption)
                .foregroundStyle(LunoColors.text1)
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: LunoTheme.Spacing.sm) {
            sectionHeader(title: "About", icon: "info.circle")

            HStack {
                Text("Version")
                    .foregroundStyle(LunoColors.text0)
                Spacer()
                Text("\(viewModel.appVersion) (\(viewModel.buildNumber))")
                    .foregroundStyle(LunoColors.text1)
            }
            .padding(LunoTheme.Spacing.md)
            .lunoGlassSurface(cornerRadius: LunoTheme.CornerRadius.card, fill: LunoColors.surface1)
        }
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: LunoTheme.Spacing.xs) {
            Image(systemName: icon)
                .foregroundStyle(LunoColors.brand500)
            Text(title)
                .font(LunoTheme.Typography.caption)
                .foregroundStyle(LunoColors.text1)
                .textCase(.uppercase)
                .tracking(1.2)
        }
    }
}

// MARK: - Preview

#Preview("Settings") {
    SettingsView()
}
