import SwiftUI

struct EditOtpEntryView: View {
    @Bindable var otp: OtpEntry
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    private func save() {
        do {
            try modelContext.save()
            DispatchQueue.main.async { dismiss() }
        } catch {
            // TODO: Handle this with an alert
        }
    }
    
    var body: some View {
        Form {
            Section {
                OVTextField("Account Name", text: $otp.accountName)
                OVTextField("Issuer", text: $otp.issuer)
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
#endif
    }
}

#Preview {
    EditOtpEntryView(otp: .testTotp30sec)
        .previewEnvironment()
}
