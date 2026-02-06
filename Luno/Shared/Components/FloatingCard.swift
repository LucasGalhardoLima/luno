import SwiftUI

// MARK: - Floating Card

// Reusable card component for displaying notes
// Constitution: Consistent visual design with micro-transitions

struct FloatingCard<Content: View>: View {
    // MARK: - Properties

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false

    let content: Content
    let isSelected: Bool
    let onTap: (() -> Void)?

    // MARK: - Initialization

    init(
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.isSelected = isSelected
        self.onTap = onTap
    }

    // MARK: - Body

    var body: some View {
        content
            .padding(LunoTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LunoColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.card))
            .overlay {
                RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.card)
                    .strokeBorder(
                        isSelected ? LunoColors.primary : .clear,
                        lineWidth: isSelected ? 2 : 0
                    )
            }
            .cardShadow()
            .scaleEffect(isPressed ? MicroTransitions.Scale.pressed : MicroTransitions.Scale.normal)
            .animation(
                reduceMotion ? nil : MicroTransitions.buttonPress,
                value: isPressed
            )
            .onTapGesture {
                onTap?()
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard onTap != nil else { return }
                        isPressed = true
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
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
        FloatingCard(isSelected: isSelected, onTap: onTap) {
            VStack(alignment: .leading, spacing: LunoTheme.Spacing.sm) {
                // Header with source type and pin indicator
                HStack {
                    Image(systemName: note.sourceType == .voice ? "mic.fill" : "text.alignleft")
                        .font(LunoTheme.Typography.caption)
                        .foregroundStyle(LunoColors.textSecondary)

                    Spacer()

                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(LunoTheme.Typography.caption)
                            .foregroundStyle(LunoColors.primary)
                    }

                    CategoryBadge(category: note.category)
                }

                // Content preview
                Text(note.content)
                    .font(LunoTheme.Typography.body)
                    .foregroundStyle(LunoColors.textPrimary)
                    .lineLimit(3)

                // Footer with date
                Text(note.modifiedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(LunoTheme.Typography.caption)
                    .foregroundStyle(LunoColors.textSecondary)
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
