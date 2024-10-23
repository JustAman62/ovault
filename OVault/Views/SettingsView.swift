import SwiftUI

struct SettingsView: View {
    @AppStorage("iconsEnabled") private var iconsEnabled: Bool = false

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
        }
        .formStyle(.grouped)
    }
}

#Preview {
    SettingsView()
}
