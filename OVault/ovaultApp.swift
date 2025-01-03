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
        .floatWindowIfSupportedAndEnabled()

#if os(macOS)
        Settings {
            SettingsView()
        }
        .floatWindowIfSupportedAndEnabled()
#endif
    }
}
