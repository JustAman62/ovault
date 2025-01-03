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
                .frame(minWidth: 300, minHeight: 100)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 500, height: 350)
        .floatWindowIfSupportedAndEnabled()
        
#if os(macOS)
        Settings {
            SettingsView()
        }
        .windowResizability(.contentMinSize)
        .floatWindowIfSupportedAndEnabled()
        
        MenuBarExtra("OVault", image: "MenuBar", isInserted: $showMenuBarButton) {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
#endif
    }
}
