import SwiftData
import SwiftUI

// MARK: - Luno App

// Main application entry point
// Constitution: Use SwiftData ModelContainer for persistence

@main
struct LunoApp: App {
    // MARK: - Properties

    /// App-wide state
    @State private var appState = AppState()

    /// SwiftData model container
    let modelContainer: ModelContainer

    /// Note repository created eagerly for fast launch
    let noteRepository: NoteRepository

    /// Categorization orchestrator for AI-powered PARA categorization
    let categorizationService: CategorizationService

    // MARK: - Initialization

    init() {
        do {
            let schema = Schema([
                Note.self,
                TrainingExample.self,
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none // Enable later: .private("iCloud.com.luno.app")
            )

            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            modelContainer = container
            noteRepository = NoteRepository(modelContainer: container)

            // Build categorization config with API key
            let apiKey: String = {
                if let saved = UserDefaults.standard.string(forKey: "luno.claude.apiKey"), !saved.isEmpty {
                    return saved
                }
                if let envKey = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"] {
                    return envKey
                }
                return ""
            }()

            let config = CategorizationConfig(
                confidenceThreshold: UserDefaults.standard.object(forKey: "luno.categorization.confidenceThreshold") as? Double ?? 0.8,
                claudeApiKey: apiKey,
                claudeModel: UserDefaults.standard.string(forKey: "luno.claude.model") ?? "claude-sonnet-4-20250514"
            )

            let trainingRepository = TrainingRepository(modelContainer: container)
            categorizationService = CategorizationService(
                onDeviceService: OnDeviceCategorizationService(),
                cloudService: ClaudeCategorizationService(config: config),
                trainingRepository: trainingRepository,
                config: config
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView(noteRepository: noteRepository, categorizationService: categorizationService)
                .environment(appState)
                .modelContainer(modelContainer)
        }
    }
}
