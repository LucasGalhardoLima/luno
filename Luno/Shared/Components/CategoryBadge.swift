import SwiftUI

// MARK: - Category Badge

// Badge component displaying PARA category with color coding
// Constitution: Visual consistency with PARA color system

struct CategoryBadge: View {
    // MARK: - Properties

    let category: PARACategory
    let style: BadgeStyle

    // MARK: - Initialization

    init(category: PARACategory, style: BadgeStyle = .compact) {
        self.category = category
        self.style = style
    }

    // MARK: - Computed Properties

    private var categoryColor: Color {
        LunoColors.PARA.color(for: category.rawValue)
    }

    // MARK: - Body

    var body: some View {
        Group {
            switch style {
            case .compact:
                compactBadge
            case .expanded:
                expandedBadge
            case .pill:
                pillBadge
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(category.displayName) category")
    }

    // MARK: - Badge Styles

    private var compactBadge: some View {
        HStack(spacing: LunoTheme.Spacing.xxs) {
            Circle()
                .fill(categoryColor)
                .frame(width: 8, height: 8)

            Text(category.displayName)
                .font(LunoTheme.Typography.caption)
                .foregroundStyle(LunoColors.textSecondary)
        }
    }

    private var expandedBadge: some View {
        HStack(spacing: LunoTheme.Spacing.xs) {
            Image(systemName: category.iconName)
                .font(LunoTheme.Typography.footnote)
                .foregroundStyle(categoryColor)

            Text(category.displayName)
                .font(LunoTheme.Typography.footnote)
                .fontWeight(.medium)
                .foregroundStyle(LunoColors.textPrimary)
        }
        .padding(.horizontal, LunoTheme.Spacing.sm)
        .padding(.vertical, LunoTheme.Spacing.xxs)
        .background(categoryColor.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.sm))
    }

    private var pillBadge: some View {
        Text(category.displayName)
            .font(LunoTheme.Typography.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, LunoTheme.Spacing.sm)
            .padding(.vertical, LunoTheme.Spacing.xxs)
            .background(categoryColor)
            .clipShape(Capsule())
    }
}

// MARK: - Badge Style

extension CategoryBadge {
    enum BadgeStyle {
        /// Minimal dot + text
        case compact
        /// Icon + text with background
        case expanded
        /// Solid pill shape
        case pill
    }
}

// MARK: - Preview

#Preview("Category Badges") {
    VStack(spacing: LunoTheme.Spacing.lg) {
        // Compact style
        VStack(alignment: .leading, spacing: LunoTheme.Spacing.sm) {
            Text("Compact Style")
                .font(LunoTheme.Typography.headline)

            ForEach(PARACategory.allCases, id: \.self) { category in
                CategoryBadge(category: category, style: .compact)
            }
        }

        Divider()

        // Expanded style
        VStack(alignment: .leading, spacing: LunoTheme.Spacing.sm) {
            Text("Expanded Style")
                .font(LunoTheme.Typography.headline)

            ForEach(PARACategory.allCases, id: \.self) { category in
                CategoryBadge(category: category, style: .expanded)
            }
        }

        Divider()

        // Pill style
        VStack(alignment: .leading, spacing: LunoTheme.Spacing.sm) {
            Text("Pill Style")
                .font(LunoTheme.Typography.headline)

            HStack {
                ForEach(PARACategory.allCases, id: \.self) { category in
                    CategoryBadge(category: category, style: .pill)
                }
            }
        }
    }
    .padding()
    .background(LunoColors.background)
}
