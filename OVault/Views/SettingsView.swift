import SwiftUI
import Models

struct SettingsView: View {
    @AppStorage("iconsEnabled", store: UserDefaults.appGroup) private var iconsEnabled: Bool = false
    @AppStorage("widgetShowsOpenInAppButton", store: UserDefaults.appGroup) private var widgetShowsOpenInAppButton: Bool = false
    @AppStorage("floatWindow", store: UserDefaults.appGroup) private var floatWindow: Bool = false
    @AppStorage("showMenuBarButton", store: UserDefaults.appGroup) private var showMenuBarButton: Bool = true
    @AppStorage("lockEnabled", store: UserDefaults.appGroup) private var lockEnabled: Bool = false
    
    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    private var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    var body: some View {
        Form {
            Section {
                Toggle("Display Domain Icons", isOn: $iconsEnabled)
            } header: {
                Text("OTP")
            } footer: {
                Text("""
                    If enabled, icons for OTPs configured with Domain Names will have the relevant icon downloaded from [Logo.dev](https://logo.dev).

                    If not enabled, no requests will be made to [Logo.dev](https://logo.dev).
                    """)
            }

            Section {
                Toggle("Show \"Open OVault\" Button", isOn: $widgetShowsOpenInAppButton)
            } header: {
                Text("Widgets")
            } footer: {
                Text("""
                    If enabled, the bottom row of OTPs in the widget will be replaced with an "Open OVault" button as a shortcut to open the app.
                    """)
            }
            
            Section {
                Toggle("Lock App On Launch", isOn: $lockEnabled)
            } header: {
                Text("Security")
            } footer: {
                Text("""
                    If enabled, the app will require the user to be authenticated by the device to see your OTPs. This can be done with the devices passcode, or biometrics such as Face ID.
                    """)
            }
            
#if os(macOS)
            Section {
                Toggle("Always On Top", isOn: $floatWindow)
            } header: {
                Text("Window")
            } footer: {
                Text("""
                    If enabled, the OVault app window will always float above all other windows. The app must be quit and restarted for a change to this setting to take effect.
                    """)
            }
            
            Section {
                Toggle("Show Menu Bar Button", isOn: $showMenuBarButton)
            } header: {
                Text("Menu Bar")
            } footer: {
                Text("""
                    If enabled, an OVault button will be added to your Menu Bar. Clicking this button will show all your OTPs allowing you to quickly view and copy them.
                    """)
            }
#endif
            
            Section("About") {
                LabeledContent("Version", value: version)
                LabeledContent("Build", value: build)
                LabeledContent("GitHub") {
                    Text("[JustAman62/ovault](https://github.com/JustAman62/ovault)")
                }
                LabeledContent("Website") {
                    Text("[ovault.net](https://ovault.net)")
                }
                LabeledContent("Developer") {
                    Text("[Aman Dhoot](https://amandhoot.com)")
                }
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    SettingsView()
}
