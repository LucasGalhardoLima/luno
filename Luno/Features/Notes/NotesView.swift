import SwiftUI

// MARK: - Notes View

// Displays all notes as floating cards with search and filter
// Constitution: Smooth animations with staggered card reveals

struct NotesView: View {
    // MARK: - Properties

    @State private var viewModel: NotesViewModel
    @State private var selectedNote: Note?
    @State private var showSettings = false

    private let noteRepository: any NoteRepositoryProtocol

    // MARK: - Initialization

    init(noteRepository: any NoteRepositoryProtocol) {
        self.noteRepository = noteRepository
        _viewModel = State(initialValue: NotesViewModel(noteRepository: noteRepository))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                LunoColors.background
                    .ignoresSafeArea()

                if viewModel.isLoading, viewModel.notes.isEmpty {
                    ProgressView()
                        .tint(LunoColors.primary)
                } else if viewModel.notes.isEmpty {
                    emptyStateView
                } else {
                    notesList
                }
            }
            .navigationTitle("Notes")
            .searchable(text: $viewModel.searchText, prompt: "Search notes")
            .onChange(of: viewModel.searchText) { _, newValue in
                Task {
                    await viewModel.search(query: newValue)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: LunoTheme.Spacing.sm) {
                        categoryFilterMenu

                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(LunoColors.primary)
                        }
                        .accessibilityLabel("Settings")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .task {
                await viewModel.fetchNotes()
            }
            .refreshable {
                await viewModel.fetchNotes()
            }
            .navigationDestination(item: $selectedNote) { note in
                NoteDetailView(note: note, noteRepository: noteRepository)
            }
        }
    }

    // MARK: - Notes List

    private var notesList: some View {
        ScrollView {
            LazyVStack(spacing: LunoTheme.Spacing.sm) {
                ForEach(Array(viewModel.notes.enumerated()), id: \.element.id) { index, note in
                    NoteCard(note: note) {
                        selectedNote = note
                    }
                    .staggeredAnimation(index: index)
                    .contextMenu {
                        noteContextMenu(for: note)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task { await viewModel.deleteNote(note) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, LunoTheme.Spacing.md)
            .padding(.vertical, LunoTheme.Spacing.sm)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: LunoTheme.Spacing.md) {
            Image(systemName: "note.text")
                .font(LunoTheme.Typography.largeTitle)
                .foregroundStyle(LunoColors.textSecondary.opacity(0.5))
                .imageScale(.large)

            Text("No Notes Yet")
                .font(LunoTheme.Typography.title2)
                .foregroundStyle(LunoColors.textPrimary)

            Text("Capture your first note using the\nCapture tab")
                .font(LunoTheme.Typography.body)
                .foregroundStyle(LunoColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Category Filter

    private var categoryFilterMenu: some View {
        Menu {
            Button {
                viewModel.selectedCategory = nil
                Task { await viewModel.fetchNotes() }
            } label: {
                HStack {
                    Text("All Notes")
                    if viewModel.selectedCategory == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Divider()

            ForEach(PARACategory.allCases, id: \.self) { category in
                Button {
                    viewModel.selectedCategory = category
                    Task { await viewModel.fetchNotes() }
                } label: {
                    HStack {
                        Image(systemName: category.iconName)
                        Text(category.displayName)
                        if viewModel.selectedCategory == category {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: viewModel.selectedCategory != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                .foregroundStyle(LunoColors.primary)
        }
        .accessibilityLabel(
            viewModel.selectedCategory.map { "Filter: \($0.displayName)" }
                ?? "Filter by category"
        )
        .accessibilityHint("Double tap to choose a category filter")
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func noteContextMenu(for note: Note) -> some View {
        Button {
            Task { await viewModel.togglePin(note) }
        } label: {
            Label(
                note.isPinned ? "Unpin" : "Pin",
                systemImage: note.isPinned ? "pin.slash" : "pin"
            )
        }

        Divider()

        Button(role: .destructive) {
            Task { await viewModel.deleteNote(note) }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

// MARK: - Preview

#Preview("Notes View") {
    let repo = MockNoteRepository()
    let _ = { // swiftformat:disable:next redundantLet
        repo.notes = [
            Note(content: "Finish landing page redesign by Friday", sourceType: .voice, category: .project, isPinned: true),
            Note(content: "Weekly health metrics review and exercise tracking", sourceType: .text, category: .area),
            Note(content: "Great article about SwiftUI performance optimization techniques", sourceType: .text, category: .resource),
            Note(content: "Q3 marketing campaign completed successfully", sourceType: .voice, category: .archive),
            Note(content: "New idea for the app feature", sourceType: .voice, category: .uncategorized)
        ]
    }()

    NotesView(noteRepository: repo)
}
