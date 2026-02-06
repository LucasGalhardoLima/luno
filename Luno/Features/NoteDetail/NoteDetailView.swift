import SwiftUI

// MARK: - Note Detail View

// Full note view with edit, re-categorize, pin, and delete
// Constitution: User can change note category at any time

struct NoteDetailView: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: NoteDetailViewModel
    @State private var showCategoryPicker = false
    @State private var showDeleteConfirmation = false

    private let noteRepository: any NoteRepositoryProtocol

    // MARK: - Initialization

    init(note: Note, noteRepository: any NoteRepositoryProtocol) {
        self.noteRepository = noteRepository
        _viewModel = State(initialValue: NoteDetailViewModel(note: note, noteRepository: noteRepository))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            LunoColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: LunoTheme.Spacing.lg) {
                    // Metadata header
                    metadataHeader
                        .slideUpOnAppear()

                    // Category badge (tappable)
                    categorySection
                        .slideUpOnAppear(delay: 0.05)

                    // Content
                    contentSection
                        .slideUpOnAppear(delay: 0.1)
                }
                .padding(LunoTheme.Spacing.md)
            }
        }
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                toolbarMenu
            }
        }
        .sheet(isPresented: $showCategoryPicker) {
            CategoryPickerView(
                currentCategory: viewModel.note.category
            ) { newCategory in
                Task {
                    await viewModel.changeCategory(to: newCategory)
                }
            }
            .presentationDetents([.medium])
        }
        .confirmationDialog(
            "Delete Note",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteNote()
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This note will be permanently deleted.")
        }
        .onChange(of: viewModel.isDeleted) { _, deleted in
            if deleted { dismiss() }
        }
    }

    // MARK: - Metadata Header

    private var metadataHeader: some View {
        HStack(spacing: LunoTheme.Spacing.md) {
            // Source type
            HStack(spacing: LunoTheme.Spacing.xxs) {
                Image(systemName: viewModel.note.sourceType == .voice ? "mic.fill" : "text.alignleft")
                    .font(LunoTheme.Typography.caption)
                Text(viewModel.note.sourceType == .voice ? "Voice" : "Text")
                    .font(LunoTheme.Typography.caption)
            }
            .foregroundStyle(LunoColors.textSecondary)

            // Date
            Text(viewModel.note.createdAt.smartFormatted)
                .font(LunoTheme.Typography.caption)
                .foregroundStyle(LunoColors.textSecondary)

            Spacer()

            // Pin indicator
            if viewModel.note.isPinned {
                Image(systemName: "pin.fill")
                    .font(LunoTheme.Typography.caption)
                    .foregroundStyle(LunoColors.primary)
                    .accessibilityLabel("Pinned")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Created via \(viewModel.note.sourceType == .voice ? "voice" : "text"), \(viewModel.note.createdAt.smartFormatted)\(viewModel.note.isPinned ? ", Pinned" : "")")
    }

    // MARK: - Category Section

    private var categorySection: some View {
        Button {
            showCategoryPicker = true
        } label: {
            HStack(spacing: LunoTheme.Spacing.sm) {
                CategoryBadge(category: viewModel.note.category, style: .expanded)

                Image(systemName: "chevron.right")
                    .font(LunoTheme.Typography.caption2)
                    .foregroundStyle(LunoColors.textSecondary)

                Spacer()

                if viewModel.note.categoryConfidence > 0 {
                    Text("AI \(Int(viewModel.note.categoryConfidence * 100))%")
                        .font(LunoTheme.Typography.caption2)
                        .foregroundStyle(LunoColors.textSecondary)
                }
            }
            .padding(LunoTheme.Spacing.sm)
            .background(LunoColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.sm))
        }
        .accessibilityLabel("Category: \(viewModel.note.category.displayName). Tap to change.")
    }

    // MARK: - Content Section

    private var contentSection: some View {
        Group {
            if viewModel.isEditing {
                editableContent
            } else {
                readOnlyContent
            }
        }
    }

    private var readOnlyContent: some View {
        Text(viewModel.note.content)
            .font(LunoTheme.Typography.body)
            .foregroundStyle(LunoColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(LunoTheme.Spacing.md)
            .background(LunoColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.card))
            .cardShadow()
    }

    private var editableContent: some View {
        VStack(spacing: LunoTheme.Spacing.sm) {
            TextEditor(text: $viewModel.editedContent)
                .font(LunoTheme.Typography.body)
                .foregroundStyle(LunoColors.textPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 200)
                .padding(LunoTheme.Spacing.sm)
                .background(LunoColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.card))
                .overlay {
                    RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.card)
                        .strokeBorder(LunoColors.primary, lineWidth: 2)
                }

            HStack(spacing: LunoTheme.Spacing.md) {
                Button("Cancel") {
                    viewModel.cancelEditing()
                }
                .foregroundStyle(LunoColors.textSecondary)

                Spacer()

                Button("Save") {
                    Task { await viewModel.saveEdits() }
                }
                .fontWeight(.semibold)
                .foregroundStyle(LunoColors.primary)
            }
        }
    }

    // MARK: - Toolbar Menu

    private var toolbarMenu: some View {
        Menu {
            Button {
                if viewModel.isEditing {
                    Task { await viewModel.saveEdits() }
                } else {
                    viewModel.startEditing()
                }
            } label: {
                Label(
                    viewModel.isEditing ? "Save" : "Edit",
                    systemImage: viewModel.isEditing ? "checkmark" : "pencil"
                )
            }

            Button {
                Task { await viewModel.togglePin() }
            } label: {
                Label(
                    viewModel.note.isPinned ? "Unpin" : "Pin",
                    systemImage: viewModel.note.isPinned ? "pin.slash" : "pin"
                )
            }

            Button {
                showCategoryPicker = true
            } label: {
                Label("Change Category", systemImage: "folder")
            }

            Divider()

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(LunoColors.primary)
        }
        .accessibilityLabel("Note actions")
        .accessibilityHint("Double tap to show edit, pin, and delete options")
    }
}

// MARK: - Preview

#Preview("Note Detail") {
    let note = Note(
        content: "Finish the landing page redesign by Friday. Need to coordinate with the design team and deploy to staging environment.",
        sourceType: .voice,
        category: .project,
        categoryConfidence: 0.92,
        categoryReasoning: "Contains deadline and specific deliverable",
        isPinned: true
    )

    NavigationStack {
        NoteDetailView(note: note, noteRepository: MockNoteRepository())
    }
}
