import SwiftUI

// MARK: - Categorization Sheet

// Sheet displaying AI categorization suggestion with accept/change options
// Constitution: User confirmation before applying AI suggestions

struct CategorizationSheet: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let note: Note
    let categorizationResult: CategorizedNote?
    let isCategorizing: Bool
    let onAccept: (PARACategory) async -> Void
    let onSkip: () -> Void

    @State private var selectedCategory: PARACategory
    @State private var hasAppeared = false

    // MARK: - Initialization

    init(
        note: Note,
        categorizationResult: CategorizedNote?,
        isCategorizing: Bool,
        onAccept: @escaping (PARACategory) async -> Void,
        onSkip: @escaping () -> Void
    ) {
        self.note = note
        self.categorizationResult = categorizationResult
        self.isCategorizing = isCategorizing
        self.onAccept = onAccept
        self.onSkip = onSkip
        _selectedCategory = State(initialValue: categorizationResult?.result.category ?? .uncategorized)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: LunoTheme.Spacing.lg) {
                // Note preview
                notePreview
                    .slideUpOnAppear(delay: 0.05)

                if isCategorizing, categorizationResult == nil {
                    loadingView
                } else {
                    // AI suggestion (if available)
                    if let result = categorizationResult {
                        suggestionView(result: result)
                            .slideUpOnAppear(delay: 0.1)
                    }

                    // Category options (always shown when not loading)
                    categoryPicker
                        .slideUpOnAppear(delay: 0.15)
                }

                Spacer()

                // Action buttons
                actionButtons
                    .slideUpOnAppear(delay: 0.2)
            }
            .padding(LunoTheme.Spacing.md)
            .background(LunoColors.background)
            .navigationTitle("Categorize Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        onSkip()
                        dismiss()
                    }
                    .foregroundStyle(LunoColors.textSecondary)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onChange(of: categorizationResult?.result.category) { _, newCategory in
            if let newCategory {
                selectedCategory = newCategory
            }
        }
    }

    // MARK: - Note Preview

    private var notePreview: some View {
        VStack(alignment: .leading, spacing: LunoTheme.Spacing.xs) {
            HStack {
                Image(systemName: note.sourceType == .voice ? "mic.fill" : "text.alignleft")
                    .font(LunoTheme.Typography.caption)
                    .foregroundStyle(LunoColors.textSecondary)

                Text("Note Preview")
                    .font(LunoTheme.Typography.caption)
                    .foregroundStyle(LunoColors.textSecondary)
            }

            Text(note.content)
                .font(LunoTheme.Typography.body)
                .foregroundStyle(LunoColors.textPrimary)
                .lineLimit(3)
        }
        .padding(LunoTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LunoColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.card))
        .subtleShadow()
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: LunoTheme.Spacing.md) {
            ProgressView()
                .tint(LunoColors.primary)

            Text("Analyzing note...")
                .font(LunoTheme.Typography.body)
                .foregroundStyle(LunoColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LunoTheme.Spacing.xl)
    }

    // MARK: - Suggestion View

    private func suggestionView(result: CategorizedNote) -> some View {
        VStack(alignment: .leading, spacing: LunoTheme.Spacing.sm) {
            // AI badge
            HStack(spacing: LunoTheme.Spacing.xs) {
                Image(systemName: result.source == .onDevice ? "cpu" : "cloud")
                    .font(LunoTheme.Typography.caption)
                    .foregroundStyle(LunoColors.primary)

                Text(result.source == .onDevice ? "On-device AI" : "Cloud AI")
                    .font(LunoTheme.Typography.caption)
                    .foregroundStyle(LunoColors.textSecondary)

                Spacer()

                // Confidence indicator
                confidenceIndicator(confidence: result.result.confidence)
            }

            // Reasoning
            Text(result.result.reasoning)
                .font(LunoTheme.Typography.callout)
                .foregroundStyle(LunoColors.textPrimary)
                .italic()
        }
        .padding(LunoTheme.Spacing.md)
        .background(LunoColors.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.md))
    }

    // MARK: - Confidence Indicator

    private func confidenceIndicator(confidence: Double) -> some View {
        HStack(spacing: LunoTheme.Spacing.xxs) {
            Image(systemName: confidenceIcon(for: confidence))
                .font(LunoTheme.Typography.caption2)

            Text("\(Int(confidence * 100))%")
                .font(LunoTheme.Typography.caption2)
                .fontWeight(.medium)
        }
        .foregroundStyle(confidenceColor(for: confidence))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Confidence: \(Int(confidence * 100)) percent")
    }

    private func confidenceIcon(for confidence: Double) -> String {
        switch confidence {
        case 0.8...: "checkmark.circle.fill"
        case 0.5...: "exclamationmark.circle.fill"
        default: "questionmark.circle.fill"
        }
    }

    private func confidenceColor(for confidence: Double) -> Color {
        switch confidence {
        case 0.8...: LunoColors.State.success
        case 0.5...: LunoColors.State.warning
        default: LunoColors.State.error
        }
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: LunoTheme.Spacing.sm) {
            Text("Category")
                .font(LunoTheme.Typography.headline)
                .foregroundStyle(LunoColors.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LunoTheme.Spacing.sm) {
                ForEach(PARACategory.paraCategories, id: \.self) { category in
                    categoryOption(category)
                }
            }
        }
    }

    private func categoryOption(_ category: PARACategory) -> some View {
        Button {
            withAnimation(MicroTransitions.fast) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: LunoTheme.Spacing.xs) {
                Image(systemName: category.iconName)
                    .font(LunoTheme.Typography.body)

                Text(category.displayName)
                    .font(LunoTheme.Typography.callout)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, LunoTheme.Spacing.sm)
            .background(
                selectedCategory == category
                    ? LunoColors.PARA.color(for: category.rawValue).opacity(0.15)
                    : LunoColors.cardBackground
            )
            .foregroundStyle(
                selectedCategory == category
                    ? LunoColors.PARA.color(for: category.rawValue)
                    : LunoColors.textSecondary
            )
            .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.button))
            .overlay {
                RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.button)
                    .strokeBorder(
                        selectedCategory == category
                            ? LunoColors.PARA.color(for: category.rawValue)
                            : LunoColors.textSecondary.opacity(0.2),
                        lineWidth: selectedCategory == category ? 2 : 1
                    )
            }
        }
        .scaleButtonStyle()
        .accessibilityLabel("\(category.displayName) category")
        .accessibilityAddTraits(selectedCategory == category ? .isSelected : [])
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        Button {
            Task {
                await onAccept(selectedCategory)
                dismiss()
            }
        } label: {
            Text("Confirm")
                .font(LunoTheme.Typography.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LunoTheme.Spacing.md)
                .background(LunoColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.button))
        }
        .scaleButtonStyle()
    }
}

// MARK: - Preview

#Preview("Categorization Sheet") {
    let note = Note(content: "Finish the landing page redesign by Friday. Need to coordinate with the design team.")
    let result = CategorizedNote(
        result: CategorizationResult(
            category: .project,
            reasoning: "This note contains a deadline (Friday) and a specific deliverable (landing page redesign), indicating a project.",
            confidence: 0.92
        ),
        source: .onDevice,
        processingTime: 0.5
    )

    CategorizationSheet(
        note: note,
        categorizationResult: result,
        isCategorizing: false,
        onAccept: { _ in },
        onSkip: {}
    )
}
