import SwiftData
import SwiftUI

// MARK: - Content View

// Main app container with tab navigation
// Constitution: Three-screen navigation (Capture, Notes, Folders)

struct ContentView: View {
    // MARK: - Properties

    @Environment(AppState.self) private var appState

    /// Note repository injected from LunoApp
    let noteRepository: any NoteRepositoryProtocol

    /// Categorization service injected from LunoApp
    let categorizationService: any CategorizationOrchestratorProtocol

    // MARK: - Body

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            CaptureView(noteRepository: noteRepository, categorizationService: categorizationService, appState: appState)
                .tabItem {
                    Label(AppTab.capture.title, systemImage: AppTab.capture.iconName)
                }
                .tag(AppTab.capture)

            NotesView(noteRepository: noteRepository)
                .tabItem {
                    Label(AppTab.notes.title, systemImage: AppTab.notes.iconName)
                }
                .tag(AppTab.notes)

            FoldersView(noteRepository: noteRepository)
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
    }
}

// MARK: - Preview

#Preview {
    ContentView(noteRepository: MockNoteRepository(), categorizationService: MockCategorizationOrchestrator())
        .environment(AppState())
}
