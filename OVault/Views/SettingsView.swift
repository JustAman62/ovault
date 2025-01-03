import SwiftUI
import Models

struct SettingsView: View {
    @AppStorage("iconsEnabled", store: UserDefaults.appGroup) private var iconsEnabled: Bool = false
    @AppStorage("widgetShowsOpenInAppButton", store: UserDefaults.appGroup) private var widgetShowsOpenInAppButton: Bool = false
    
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
                    If enabled, the bottom row of OTPs in the widget will be replaced with a "Open OVault" button as a shortcut to open the app.
                    """)
            }
            
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
