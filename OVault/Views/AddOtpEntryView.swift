import SwiftUI
import Models

struct AddOtpEntryView: View {
    @State private var newEntry: OtpMetadata = .blank()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.notifier) private var notifier
    
    private func save() {
        notifier.execute {
            modelContext.insert(newEntry)
            try modelContext.save()
            DispatchQueue.main.async { dismiss() }
        }
    }
    
    var body: some View {
        Form {
            Section {
                OVTextField("Account Name", text: $newEntry.accountName)
                OVTextField("Issuer", text: $newEntry.issuer)
            }
            
            OVTextField("Secret", text: $newEntry.secret)
            
            Picker("Algorithm", selection: $newEntry.algorithm) {
                ForEach(HashAlgorithm.allCases) { alg in
                    Text(alg.rawValue).tag(alg)
                }
            }
            
            Picker("Length", selection: $newEntry.digits) {
                Text("6").tag(6)
                Text("7").tag(7)
                Text("8").tag(8)
            }
            
            Picker("Type", selection: $newEntry.type) {
                ForEach(OtpType.allCases, id: \.rawValue) { type in
                    Text(type.rawValue.uppercased()).tag(type)
                }
            }
            
            switch newEntry.type {
            case .totp:
                Picker("Period", selection: $newEntry.period) {
                    Text("15 Seconds").tag(15)
                    Text("30 Seconds").tag(30)
                    Text("45 Seconds").tag(45)
                    Text("60 Seconds").tag(60)
                }
            case .hotp:
                LabeledContent {
                    TextField(value: $newEntry.counter, format: .number, label: { EmptyView() })
                } label: {
                    Text("Counter")
                }
            @unknown default:
                EmptyView()
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
        .navigationTitle("New OTP")
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
    NavigationStack {
        AddOtpEntryView()
    }
}
