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

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
    }
}
