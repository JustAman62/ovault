import SwiftUI
import Models
import AppIntents

@main
struct OVaultApp: App {
    @AppStorage("showMenuBarButton", store: UserDefaults.appGroup) private var showMenuBarButton: Bool = true
    
    var body: some Scene {
        WindowGroup("OVault", id: "otp-list") {
            ContentView()
                .withNotifierSupport()
        }
        .floatWindowIfSupportedAndEnabled()
        
#if os(macOS)
        Settings {
            SettingsView()
        }
        .floatWindowIfSupportedAndEnabled()
        
        MenuBarExtra("OVault", image: "MenuBar", isInserted: $showMenuBarButton) {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
#endif
    }
}
