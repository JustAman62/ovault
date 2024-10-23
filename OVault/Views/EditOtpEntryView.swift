import SwiftUI
import Models

struct EditOtpEntryView: View {
    @State private var otp: Otp
    @State private var secretShown: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.notifier) private var notifier
    @Environment(\.keychain) private var keychain
    @Environment(\.refresh) private var refresh
    
    init(otp: Otp) {
        self._otp = State(initialValue: otp)
        self.secretShown = false
    }
    
    private func save() async {
        await notifier.execute {
            try await keychain.update(otp: otp)
            await refresh?()
            DispatchQueue.main.async { dismiss() }
        }
    }
    
    var body: some View {
        VStack {
            Form {
                Section {
                    OVTextField("Account Name", text: $otp.accountName, placeholder: "Gold Account")
                    OVTextField("Issuer", text: $otp.issuer, placeholder: "Acme Corp")
                    HStack {
                        OVTextField("Domain", text: $otp.domainName, placeholder: "example.com")
#if !os(macOS)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
#endif
                        DomainIcon(otp: otp)
                    }
                } footer: {
                    Text("""
                         Logos provided by [Logo.dev](https://logo.dev)
                         
                         To prevent requests being made to [Logo.dev](https://logo.dev), you can either remove the Domain from this OTPs configuration, or disable Domain Icons in Settings.
                         """)
                }
                
                Section {
                    LabeledContent("Secret") {
                        if secretShown {
                            Text(otp.secret)
                                .textSelection(.enabled)
                        } else {
                            Button("Reveal Secret") {
                                secretShown.toggle()
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            
#if os(macOS)
            HStack {
                Button("Cancel", role: .cancel) {
                    DispatchQueue.main.async { dismiss() }
                }
                Spacer()
                AsyncButton("Save", action: save)
            }
            .padding()
#endif
        }
        .navigationTitle("Edit OTP")
#if !os(macOS)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                AsyncButton("Save", action: save)
            }
        }
#endif
    }
}

#if DEBUG
#Preview {
    EditOtpEntryView(otp: .testTotp15sec)
        .previewEnvironment()
}
#endif
