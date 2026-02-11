import SwiftUI

// MARK: - Floating Card

// Reusable card component for displaying notes
// Constitution: Consistent visual design with micro-transitions

struct FloatingCard<Content: View>: View {
    // MARK: - Properties

    let content: Content
    let isSelected: Bool
    let accentColor: Color?
    let onTap: (() -> Void)?

    // MARK: - Initialization

    init(
        isSelected: Bool = false,
        accentColor: Color? = nil,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.isSelected = isSelected
        self.accentColor = accentColor
        self.onTap = onTap
    }

    // MARK: - Body

    var body: some View {
        cardContent
            .onTapGesture {
                onTap?()
            }
    }

    private var cardContent: some View {
        HStack(spacing: 0) {
            if let accentColor {
                UnevenRoundedRectangle(
                    topLeadingRadius: LunoTheme.CornerRadius.card,
                    bottomLeadingRadius: LunoTheme.CornerRadius.card,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
                .fill(accentColor)
                .frame(width: 3)
            }

            content
                .padding(LunoTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .lunoGlassSurface(cornerRadius: LunoTheme.CornerRadius.card, fill: LunoColors.surface1)
        .overlay {
            RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.card, style: .continuous)
                .strokeBorder(
                    isSelected ? LunoColors.brand500 : LunoColors.lineSoft,
                    lineWidth: isSelected ? 1.5 : 1
                )
        }
        .cardShadow()
    }
}

// MARK: - Note Card

/// Specialized floating card for displaying notes
struct NoteCard: View {
    // MARK: - Properties

    let note: Note
    let isSelected: Bool
    let onTap: (() -> Void)?

    // MARK: - Initialization

    init(
        note: Note,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil
    ) {
        self.note = note
        self.isSelected = isSelected
        self.onTap = onTap
    }

    // MARK: - Body

    var body: some View {
        FloatingCard(
            isSelected: isSelected,
            accentColor: LunoColors.PARA.color(for: note.category.rawValue),
            onTap: onTap
        ) {
            VStack(alignment: .leading, spacing: LunoTheme.Spacing.sm) {
                // Header with source type and pin indicator
                HStack {
                    Image(systemName: note.sourceType == .voice ? "mic.fill" : "text.alignleft")
                        .font(LunoTheme.Typography.caption)
                        .foregroundStyle(LunoColors.text1)

                    Spacer()

                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(LunoTheme.Typography.caption)
                            .foregroundStyle(LunoColors.brand500)
                    }

                    CategoryBadge(category: note.category)
                }

                // Content preview
                Text(note.content)
                    .font(LunoTheme.Typography.body)
                    .foregroundStyle(LunoColors.text0)
                    .lineLimit(3)

                // Footer with date
                Text(note.modifiedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(LunoTheme.Typography.caption)
                    .foregroundStyle(LunoColors.text1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(noteAccessibilityLabel)
        .accessibilityHint(onTap != nil ? "Double tap to view details" : "")
    }

    // MARK: - Accessibility

    private var noteAccessibilityLabel: String {
        var parts: [String] = []
        if note.isPinned { parts.append("Pinned") }
        parts.append("\(note.category.displayName) note")
        parts.append(note.content)
        parts.append("Created via \(note.sourceType == .voice ? "voice" : "text")")
        parts.append(note.modifiedAt.formatted(date: .abbreviated, time: .shortened))
        return parts.joined(separator: ". ")
    }
}

// MARK: - Preview

#Preview("Floating Card") {
    VStack(spacing: LunoTheme.Spacing.md) {
        FloatingCard {
            Text("Simple floating card content")
                .font(LunoTheme.Typography.body)
        }

        FloatingCard(isSelected: true) {
            Text("Selected card")
                .font(LunoTheme.Typography.body)
        }
    }
    .padding()
    .background(LunoColors.background)
}

#Preview("Note Card") {
    let sampleNote = Note(
        content: "This is a sample note with some content that might span multiple lines to show how the card handles longer text.",
        sourceType: .voice,
        category: .project,
        isPinned: true
    )

    NoteCard(note: sampleNote)
        .padding()
        .background(LunoColors.background)
}
