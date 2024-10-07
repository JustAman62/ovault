import SwiftUI
import Models
import AppIntents

@main
struct OVaultApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withNotifierSupport()
        }
    }
}
