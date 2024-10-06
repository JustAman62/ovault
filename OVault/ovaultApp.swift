import SwiftUI
import Models

@main
struct OVaultApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withNotifierSupport()
        }
    }
}
