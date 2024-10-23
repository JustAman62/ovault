import SwiftUI

struct SettingsView: View {
    @AppStorage("iconsEnabled") private var iconsEnabled: Bool = false
    
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
            } footer: {
                Text("""
                    If enabled, icons for OTPs configured with Domain Names will have the relevant icon downloaded from [Logo.dev](https://logo.dev).

                    If not enabled, no requests will be made to [Logo.dev](https://logo.dev).
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
