import SwiftUI

// MARK: - Folders View

// PARA category folders with note counts
// Constitution: Three-screen navigation - Folders tab

struct FoldersView: View {
    // MARK: - Properties

    @State private var viewModel: FoldersViewModel
    @State private var selectedCategory: PARACategory?

    private let noteRepository: any NoteRepositoryProtocol

    // MARK: - Initialization

    init(noteRepository: any NoteRepositoryProtocol) {
        self.noteRepository = noteRepository
        _viewModel = State(initialValue: FoldersViewModel(noteRepository: noteRepository))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                LunoColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LunoTheme.Spacing.lg) {
                        // Summary header
                        summaryHeader
                            .slideUpOnAppear()

                        // PARA folder grid
                        folderGrid

                        // Uncategorized section
                        if viewModel.noteCount(for: .uncategorized) > 0 {
                            uncategorizedSection
                                .slideUpOnAppear(delay: 0.25)
                        }
                    }
                    .padding(.horizontal, LunoTheme.Spacing.md)
                    .padding(.vertical, LunoTheme.Spacing.sm)
                }
            }
            .navigationTitle("Folders")
            .task {
                await viewModel.fetchCounts()
            }
            .refreshable {
                await viewModel.fetchCounts()
            }
            .navigationDestination(item: $selectedCategory) { category in
                FolderNotesView(
                    category: category,
                    noteRepository: noteRepository
                )
            }
        }
    }

    // MARK: - Summary Header

    private var summaryHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: LunoTheme.Spacing.xxs) {
                Text("\(viewModel.totalNoteCount)")
                    .font(LunoTheme.Typography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(LunoColors.textPrimary)

                Text("Total Notes")
                    .font(LunoTheme.Typography.subheadline)
                    .foregroundStyle(LunoColors.textSecondary)
            }

            Spacer()
        }
    }

    // MARK: - Folder Grid

    private var folderGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: LunoTheme.Spacing.md
        ) {
            ForEach(Array(PARACategory.paraCategories.enumerated()), id: \.element) { index, category in
                FolderCardView(
                    category: category,
                    noteCount: viewModel.noteCount(for: category)
                ) {
                    selectedCategory = category
                }
                .staggeredAnimation(index: index, baseDelay: 0.05)
            }
        }
    }

    // MARK: - Uncategorized Section

    private var uncategorizedSection: some View {
        Button {
            selectedCategory = .uncategorized
        } label: {
            HStack(spacing: LunoTheme.Spacing.sm) {
                Image(systemName: PARACategory.uncategorized.iconName)
                    .font(LunoTheme.Typography.body)
                    .foregroundStyle(LunoColors.PARA.uncategorized)

                Text("Uncategorized")
                    .font(LunoTheme.Typography.headline)
                    .foregroundStyle(LunoColors.textPrimary)

                Spacer()

                Text("\(viewModel.noteCount(for: .uncategorized))")
                    .font(LunoTheme.Typography.body)
                    .fontWeight(.medium)
                    .foregroundStyle(LunoColors.textSecondary)

                Image(systemName: "chevron.right")
                    .font(LunoTheme.Typography.caption)
                    .foregroundStyle(LunoColors.textSecondary)
            }
            .padding(LunoTheme.Spacing.md)
            .background(LunoColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.card))
            .cardShadow()
        }
        .scaleButtonStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Uncategorized, \(viewModel.noteCount(for: .uncategorized)) \(viewModel.noteCount(for: .uncategorized) == 1 ? "note" : "notes")")
        .accessibilityHint("Double tap to view uncategorized notes")
    }
}

// MARK: - Folder Notes View

/// Displays notes filtered by a specific PARA category
struct FolderNotesView: View {
    // MARK: - Properties

    let category: PARACategory
    @State private var notes: [Note] = []
    @State private var isLoading = true
    @State private var selectedNote: Note?

    private let noteRepository: any NoteRepositoryProtocol

    // MARK: - Initialization

    init(category: PARACategory, noteRepository: any NoteRepositoryProtocol) {
        self.category = category
        self.noteRepository = noteRepository
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            LunoColors.background
                .ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .tint(LunoColors.primary)
            } else if notes.isEmpty {
                emptyState
            } else {
                notesList
            }
        }
        .navigationTitle(category.displayName)
        .task {
            await loadNotes()
        }
        .refreshable {
            await loadNotes()
        }
        .navigationDestination(item: $selectedNote) { note in
            NoteDetailView(note: note, noteRepository: noteRepository)
        }
    }

    // MARK: - Notes List

    private var notesList: some View {
        ScrollView {
            LazyVStack(spacing: LunoTheme.Spacing.sm) {
                ForEach(Array(notes.enumerated()), id: \.element.id) { index, note in
                    NoteCard(note: note) {
                        selectedNote = note
                    }
                    .staggeredAnimation(index: index)
                    .contextMenu {
                        noteContextMenu(for: note)
                    }
                }
            }
            .padding(.horizontal, LunoTheme.Spacing.md)
            .padding(.vertical, LunoTheme.Spacing.sm)
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func noteContextMenu(for note: Note) -> some View {
        // Archive / Unarchive action
        if category != .archive {
            Button {
                Task { await moveNote(note, to: .archive) }
            } label: {
                Label("Archive", systemImage: "archivebox")
            }
        } else {
            // In archive view, offer to restore to a category
            Menu {
                ForEach(PARACategory.paraCategories.filter { $0 != .archive }, id: \.self) { cat in
                    Button {
                        Task { await moveNote(note, to: cat) }
                    } label: {
                        Label(cat.displayName, systemImage: cat.iconName)
                    }
                }
            } label: {
                Label("Move to...", systemImage: "folder")
            }
        }

        // Re-categorize into another PARA folder
        if category != .archive {
            Menu {
                ForEach(PARACategory.paraCategories.filter { $0 != category }, id: \.self) { cat in
                    Button {
                        Task { await moveNote(note, to: cat) }
                    } label: {
                        Label(cat.displayName, systemImage: cat.iconName)
                    }
                }
            } label: {
                Label("Move to...", systemImage: "folder")
            }
        }

        Divider()

        Button(role: .destructive) {
            Task { await deleteNote(note) }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    // MARK: - Actions

    private func moveNote(_ note: Note, to newCategory: PARACategory) async {
        note.category = newCategory
        do {
            try await noteRepository.update(note)
            // Remove from this view since it no longer belongs to this folder
            notes.removeAll { $0.id == note.id }
        } catch {
            note.category = category // Revert
        }
    }

    private func deleteNote(_ note: Note) async {
        do {
            try await noteRepository.delete(note)
            notes.removeAll { $0.id == note.id }
        } catch {
            // Error handling
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: LunoTheme.Spacing.md) {
            Image(systemName: category.iconName)
                .font(LunoTheme.Typography.largeTitle)
                .foregroundStyle(LunoColors.PARA.color(for: category.rawValue).opacity(0.5))
                .imageScale(.large)

            Text("No \(category.displayName)")
                .font(LunoTheme.Typography.title3)
                .foregroundStyle(LunoColors.textPrimary)

            Text("Notes categorized as \(category.displayName.lowercased()) will appear here")
                .font(LunoTheme.Typography.body)
                .foregroundStyle(LunoColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, LunoTheme.Spacing.xl)
    }

    // MARK: - Data Loading

    private func loadNotes() async {
        isLoading = true
        do {
            notes = try await noteRepository.fetchNotes(category: category)
        } catch {
            // Error handling
        }
        isLoading = false
    }
}

// MARK: - Preview

#Preview("Folders View") {
    let repo = MockNoteRepository()
    let _ = { // swiftformat:disable:next redundantLet
        repo.notes = [
            Note(content: "Project 1", category: .project),
            Note(content: "Project 2", category: .project),
            Note(content: "Area 1", category: .area),
            Note(content: "Resource 1", category: .resource),
            Note(content: "Uncategorized note", category: .uncategorized),
        ]
    }()

    FoldersView(noteRepository: repo)
}
