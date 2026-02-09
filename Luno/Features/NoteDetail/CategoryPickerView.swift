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
            List {
                Section("PARA Categories") {
                    ForEach(PARACategory.paraCategories, id: \.self) { category in
                        categoryRow(category)
                    }
                }

                Section {
                    categoryRow(.uncategorized)
                }
            }
            .navigationTitle("Change Category")
            .navigationBarTitleDisplayMode(.inline)
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
                        .foregroundStyle(LunoColors.textPrimary)

                    Text(category.description)
                        .font(LunoTheme.Typography.caption)
                        .foregroundStyle(LunoColors.textSecondary)
                }

                Spacer()

                if category == currentCategory {
                    Image(systemName: "checkmark")
                        .font(LunoTheme.Typography.body)
                        .foregroundStyle(LunoColors.primary)
                }
            }
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
