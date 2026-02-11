import SwiftUI

// MARK: - Folders View

// PARA category folders with note counts
// Constitution: Three-screen navigation - Folders tab

struct FoldersView: View {
    // MARK: - Properties

    @Environment(AppState.self) private var appState
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
                LunoBackgroundView()

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
            .lunoNavChrome()
            .task {
                await viewModel.fetchCounts()
            }
            .onAppear {
                Task { await viewModel.fetchCounts() }
            }
            .onChange(of: appState.dataVersion) {
                Task { await viewModel.fetchCounts() }
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
                    .font(LunoTheme.Typography.displayMd)
                    .fontWeight(.bold)
                    .foregroundStyle(LunoColors.text0)
                    .contentTransition(.numericText())

                Text("Total Notes")
                    .font(LunoTheme.Typography.subheadline)
                    .foregroundStyle(LunoColors.text1)
            }

            Spacer()
        }
        .padding(LunoTheme.Spacing.md)
        .lunoGlassSurface(cornerRadius: LunoTheme.CornerRadius.card, fill: LunoColors.surface1)
    }

    // MARK: - Folder Grid

    private var folderGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: LunoTheme.Spacing.md
        ) {
            ForEach(Array(PARACategory.paraCategories.enumerated()), id: \.element) { indexedItem in
                let (index, category) = (indexedItem.offset, indexedItem.element)
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
                    .foregroundStyle(LunoColors.text0)

                Spacer()

                Text("\(viewModel.noteCount(for: .uncategorized))")
                    .font(LunoTheme.Typography.body)
                    .fontWeight(.medium)
                    .foregroundStyle(LunoColors.text1)
                    .contentTransition(.numericText())

                Image(systemName: "chevron.right")
                    .font(LunoTheme.Typography.caption)
                    .foregroundStyle(LunoColors.text1)
            }
            .padding(LunoTheme.Spacing.md)
            .lunoGlassSurface(cornerRadius: LunoTheme.CornerRadius.card, fill: LunoColors.surface1)
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
    @State private var errorMessage: String?

    private let noteRepository: any NoteRepositoryProtocol

    // MARK: - Initialization

    init(category: PARACategory, noteRepository: any NoteRepositoryProtocol) {
        self.category = category
        self.noteRepository = noteRepository
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            LunoBackgroundView()

            if isLoading {
                ProgressView()
                    .tint(LunoColors.brand500)
            } else if notes.isEmpty {
                emptyState
            } else {
                notesList
            }
        }
        .overlay(alignment: .bottom) {
            if let errorMessage {
                Text(errorMessage)
                    .font(LunoTheme.Typography.footnote)
                    .foregroundStyle(LunoColors.State.error)
                    .padding(LunoTheme.Spacing.sm)
                    .lunoGlassSurface(cornerRadius: LunoTheme.CornerRadius.sm, fill: LunoColors.surface2)
                    .padding(.bottom, LunoTheme.Spacing.md)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle(category.displayName)
        .lunoNavChrome()
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
                    .compositingGroup()
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
        do {
            try await noteRepository.updateCategory(noteId: note.id, category: newCategory)
            notes.removeAll { $0.id == note.id }
        } catch {
            LunoLogger.repository.error("Failed to move note \(note.id) to \(newCategory.rawValue): \(error)")
            errorMessage = "Could not move note"
        }
    }

    private func deleteNote(_ note: Note) async {
        do {
            try await noteRepository.delete(note)
            notes.removeAll { $0.id == note.id }
        } catch {
            LunoLogger.repository.error("Failed to delete note \(note.id): \(error)")
            errorMessage = "Could not delete note"
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: LunoTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(LunoColors.PARA.color(for: category.rawValue).opacity(0.12))
                    .frame(width: 64, height: 64)

                Image(systemName: category.iconName)
                    .font(LunoTheme.Typography.title)
                    .foregroundStyle(LunoColors.PARA.color(for: category.rawValue))
            }
            .accessibilityHidden(true)

            Text("No \(category.displayName)")
                .font(LunoTheme.Typography.sectionTitle)
                .foregroundStyle(LunoColors.text0)

            Text("Notes categorized as \(category.displayName.lowercased()) will appear here")
                .font(LunoTheme.Typography.body)
                .foregroundStyle(LunoColors.text1)
                .multilineTextAlignment(.center)
        }
        .padding(LunoTheme.Spacing.lg)
        .lunoGlassSurface(cornerRadius: LunoTheme.CornerRadius.card, fill: LunoColors.surface1)
        .padding(.horizontal, LunoTheme.Spacing.xl)
    }

    // MARK: - Data Loading

    private func loadNotes() async {
        isLoading = true
        errorMessage = nil
        do {
            notes = try await noteRepository.fetchNotes(category: category)
        } catch {
            LunoLogger.repository.error("Failed to fetch notes for \(category.rawValue): \(error)")
            // Fallback: fetch all and filter client-side
            do {
                let allNotes = try await noteRepository.fetchNotes(category: nil)
                notes = allNotes.filter { $0.category == category }
            } catch {
                LunoLogger.repository.error("Fallback fetch also failed: \(error)")
                errorMessage = "Could not load notes"
            }
        }
        isLoading = false
    }
}

// MARK: - Preview

#Preview("Folders View") {
    let repo = MockNoteRepository()
    // swiftlint:disable:next redundant_discardable_let
    let _ = {
        repo.notes = [
            Note(content: "Project 1", category: .project),
            Note(content: "Project 2", category: .project),
            Note(content: "Area 1", category: .area),
            Note(content: "Resource 1", category: .resource),
            Note(content: "Uncategorized note", category: .uncategorized),
        ]
    }()

    FoldersView(noteRepository: repo)
        .environment(AppState())
}
