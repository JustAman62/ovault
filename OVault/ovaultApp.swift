import SwiftUI
import Models
import AppIntents

@main
struct OVaultApp: App {
    @AppStorage("showMenuBarButton", store: UserDefaults.appGroup) private var showMenuBarButton: Bool = true
    
    var body: some Scene {
        
#if os(macOS)
        // The main OVault window (only a single instance)
        Window("OVault", id: "otp-list") {
            ContentView()
                .withNotifierSupport()
                .frame(minWidth: 300, minHeight: 100)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 500, height: 350)
        .floatWindowIfSupportedAndEnabled()
#endif
        
        // Use a WindowGroup to allow for additional windows to be opened
        // This also prevents the application from automatically quitting when the main window is closed
        WindowGroup("OVault") {
            ContentView()
                .withNotifierSupport()
                .frame(minWidth: 300, minHeight: 100)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 500, height: 350)
        .floatWindowIfSupportedAndEnabled()
#if os(macOS)
        .keyboardShortcut(.init("N"))
#endif
        
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

enum WindowName: String, Codable {
    case main
}
