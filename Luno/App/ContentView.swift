import SwiftData
import SwiftUI

// MARK: - Content View

// Main app container with tab navigation
// Constitution: Three-screen navigation (Capture, Notes, Folders)

struct ContentView: View {
    // MARK: - Properties

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    /// Note repository created from model context
    @State private var noteRepository: NoteRepository?

    // MARK: - Body

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            captureTab
                .tabItem {
                    Label(AppTab.capture.title, systemImage: AppTab.capture.iconName)
                }
                .tag(AppTab.capture)

            notesTab
                .tabItem {
                    Label(AppTab.notes.title, systemImage: AppTab.notes.iconName)
                }
                .tag(AppTab.notes)

            foldersTab
                .tabItem {
                    Label(AppTab.folders.title, systemImage: AppTab.folders.iconName)
                }
                .tag(AppTab.folders)
        }
        .tint(LunoColors.primary)
        .alert(
            "Error",
            isPresented: $appState.showErrorAlert,
            presenting: appState.currentError
        ) { _ in
            Button("OK") {
                appState.clearError()
            }
        } message: { error in
            Text(error.localizedDescription)
        }
        .task {
            if noteRepository == nil {
                noteRepository = NoteRepository(modelContainer: modelContext.container)
            }
        }
    }

    // MARK: - Tabs

    @ViewBuilder
    private var captureTab: some View {
        if let repository = noteRepository {
            CaptureView(noteRepository: repository)
        } else {
            loadingView
        }
    }

    @ViewBuilder
    private var notesTab: some View {
        if let repository = noteRepository {
            NotesView(noteRepository: repository)
        } else {
            loadingView
        }
    }

    @ViewBuilder
    private var foldersTab: some View {
        if let repository = noteRepository {
            FoldersView(noteRepository: repository)
        } else {
            loadingView
        }
    }

    private var loadingView: some View {
        ProgressView()
            .tint(LunoColors.primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(LunoColors.background)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environment(AppState())
}
