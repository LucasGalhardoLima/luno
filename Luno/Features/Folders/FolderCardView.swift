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
            HStack(spacing: 0) {
                // Full-height color accent strip
                UnevenRoundedRectangle(
                    topLeadingRadius: LunoTheme.CornerRadius.card,
                    bottomLeadingRadius: LunoTheme.CornerRadius.card,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
                .fill(categoryColor)
                .frame(width: 4)

                VStack(alignment: .leading, spacing: LunoTheme.Spacing.sm) {
                    // Icon and count
                    HStack {
                        // Category icon
                        Image(systemName: category.iconName)
                            .font(LunoTheme.Typography.body)
                            .fontWeight(.medium)
                            .foregroundStyle(categoryColor)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle().fill(categoryColor.opacity(0.12))
                            )

                        Spacer()

                        // Note count badge
                        Text("\(noteCount)")
                            .font(LunoTheme.Typography.sectionTitle)
                            .fontWeight(.semibold)
                            .foregroundStyle(LunoColors.text0)
                            .contentTransition(.numericText())
                    }

                    // Category name
                    Text(category.displayName)
                        .font(LunoTheme.Typography.headline)
                        .foregroundStyle(LunoColors.text0)

                    // Description
                    Text(category.description)
                        .font(LunoTheme.Typography.caption)
                        .foregroundStyle(LunoColors.text1)
                        .lineLimit(2)
                }
                .padding(LunoTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .lunoGlassSurface(cornerRadius: LunoTheme.CornerRadius.card, fill: LunoColors.surface1)
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
