import SwiftUI
import Models

struct EditOtpEntryView: View {
    @Bindable var otp: OtpMetadata
    
    @State private var secret: String?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.notifier) private var notifier
    @Environment(\.keychain) private var keychain
    
    private func save() {
        notifier.execute {
            try modelContext.save()
            DispatchQueue.main.async { dismiss() }
        }
    }
    
    var body: some View {
        Form {
            Section {
                OVTextField("Account Name", text: $otp.accountName)
                OVTextField("Issuer", text: $otp.issuer)
            }
            
            Section {
                LabeledContent("Secret") {
                    if let secret {
                        Text(secret)
                            .textSelection(.enabled)
                    } else {
                        Button("Reveal Secret") {
                            notifier.execute {
                                self.secret = try keychain.getSecret(metadata: otp)
                            }
                        }
                    }
                }
            }
            
#if os(macOS)
            HStack {
                Button("Cancel", role: .cancel) {
                    DispatchQueue.main.async { dismiss() }
                }
                Spacer()
                Button("Save", action: save)
            }
            .padding(.vertical)
#endif
        }
        .navigationTitle("Edit OTP")
#if os(macOS)
        .padding()
#else
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
            }
        }
        .onDisappear {
            self.secret = nil
        }
#endif
    }
}

#Preview {
    EditOtpEntryView(otp: .testTotp30sec)
        .previewEnvironment()
}
