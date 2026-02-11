import SwiftUI

// MARK: - Category Picker View

// Allows users to change a note's PARA category
// Constitution: Quick re-categorization from any note

struct CategoryPickerView: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    let currentCategory: PARACategory
    let onSelect: (PARACategory) -> Void

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                LunoBackgroundView()

                ScrollView {
                    VStack(alignment: .leading, spacing: LunoTheme.Spacing.md) {
                        Text("PARA Categories")
                            .font(LunoTheme.Typography.caption)
                            .foregroundStyle(LunoColors.text1)
                            .textCase(.uppercase)
                            .tracking(1.2)
                            .padding(.horizontal, LunoTheme.Spacing.sm)

                        VStack(spacing: LunoTheme.Spacing.xs) {
                            ForEach(PARACategory.paraCategories, id: \.self) { category in
                                categoryRow(category)
                            }
                        }
                        .padding(LunoTheme.Spacing.sm)
                        .lunoGlassSurface(cornerRadius: LunoTheme.CornerRadius.card, fill: LunoColors.surface1)

                        Text("Other")
                            .font(LunoTheme.Typography.caption)
                            .foregroundStyle(LunoColors.text1)
                            .textCase(.uppercase)
                            .tracking(1.2)
                            .padding(.horizontal, LunoTheme.Spacing.sm)
                            .padding(.top, LunoTheme.Spacing.sm)

                        VStack(spacing: LunoTheme.Spacing.xs) {
                            categoryRow(.uncategorized)
                        }
                        .padding(LunoTheme.Spacing.sm)
                        .lunoGlassSurface(cornerRadius: LunoTheme.CornerRadius.card, fill: LunoColors.surface1)
                    }
                    .padding(LunoTheme.Spacing.md)
                }
            }
            .navigationTitle("Change Category")
            .navigationBarTitleDisplayMode(.inline)
            .lunoNavChrome()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Category Row

    private func categoryRow(_ category: PARACategory) -> some View {
        Button {
            onSelect(category)
            dismiss()
        } label: {
            HStack(spacing: LunoTheme.Spacing.sm) {
                Image(systemName: category.iconName)
                    .font(LunoTheme.Typography.body)
                    .foregroundStyle(LunoColors.PARA.color(for: category.rawValue))
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: LunoTheme.Spacing.xxxs) {
                    Text(category.displayName)
                        .font(LunoTheme.Typography.body)
                        .foregroundStyle(LunoColors.text0)

                    Text(category.description)
                        .font(LunoTheme.Typography.caption)
                        .foregroundStyle(LunoColors.text1)
                }

                Spacer()

                if category == currentCategory {
                    Image(systemName: "checkmark")
                        .font(LunoTheme.Typography.body)
                        .foregroundStyle(LunoColors.brand500)
                }
            }
            .padding(LunoTheme.Spacing.sm)
            .lunoGlassSurface(cornerRadius: LunoTheme.CornerRadius.md, fill: LunoColors.surface2)
            .contentShape(Rectangle())
        }
        .accessibilityLabel("\(category.displayName): \(category.description)")
        .accessibilityAddTraits(category == currentCategory ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview("Category Picker") {
    CategoryPickerView(currentCategory: .project) { category in
        print("Selected: \(category)")
    }
}
