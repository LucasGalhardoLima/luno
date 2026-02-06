import SwiftUI

// MARK: - Folder Card View

// Card representing a PARA category folder with note count
// Constitution: Visual consistency with PARA color system

struct FolderCardView: View {
    // MARK: - Properties

    let category: PARACategory
    let noteCount: Int
    let action: () -> Void

    // MARK: - Computed

    private var categoryColor: Color {
        LunoColors.PARA.color(for: category.rawValue)
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: LunoTheme.Spacing.sm) {
                // Icon and count
                HStack {
                    // Category icon
                    Image(systemName: category.iconName)
                        .font(LunoTheme.Typography.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(categoryColor)

                    Spacer()

                    // Note count badge
                    Text("\(noteCount)")
                        .font(LunoTheme.Typography.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(LunoColors.textPrimary)
                }

                // Category name
                Text(category.displayName)
                    .font(LunoTheme.Typography.headline)
                    .foregroundStyle(LunoColors.textPrimary)

                // Description
                Text(category.description)
                    .font(LunoTheme.Typography.caption)
                    .foregroundStyle(LunoColors.textSecondary)
                    .lineLimit(2)
            }
            .padding(LunoTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LunoColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.card))
            .overlay(alignment: .topLeading) {
                // Color accent bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(categoryColor)
                    .frame(width: 4, height: 32)
                    .padding(.leading, LunoTheme.Spacing.xs)
                    .padding(.top, LunoTheme.Spacing.md)
            }
            .cardShadow()
        }
        .scaleButtonStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(category.displayName) folder, \(noteCount) \(noteCount == 1 ? "note" : "notes")")
        .accessibilityHint("Double tap to open folder")
    }
}

// MARK: - Preview

#Preview("Folder Cards") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LunoTheme.Spacing.md) {
        FolderCardView(category: .project, noteCount: 5) {}
        FolderCardView(category: .area, noteCount: 12) {}
        FolderCardView(category: .resource, noteCount: 8) {}
        FolderCardView(category: .archive, noteCount: 23) {}
    }
    .padding()
    .background(LunoColors.background)
}
