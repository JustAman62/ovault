import SwiftUI
import SwiftData
import Models

@main
struct ovaultApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            OtpEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .withNotifierSupport()
        }
        .modelContainer(sharedModelContainer)
    }
}
