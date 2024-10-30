import SwiftUI
import Models

struct AddOtpEntryView: View {
    @State private var newEntry: Otp = .blank()
    @State private var url: String = ""
    @State private var advancedExpanded: Bool = false
    @State private var tab: PageType = .manual
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.notifier) private var notifier
    @Environment(\.keychain) private var keychain
    @Environment(\.refresh) private var refresh
    
    enum PageType {
        case manual, byUrl
    }
    
    private enum ValidationError: Error, LocalizedError {
        case URLRequired
        case AccountNameRequired
        case IssuerRequired
        case SecretRequired
        
        public var errorDescription: String? {
            switch self {
            case .URLRequired:
                "A URL must be provided when adding an OTP by URL"
            case .AccountNameRequired:
                "The Account Name field must not be empty"
            case .IssuerRequired:
                "The Issuer field must not be empty"
            case .SecretRequired:
                "The Secret field must not be empty"
            }
        }
    }
    
    private func save() async {
        await notifier.execute {
            if tab == .byUrl {
                if url.isEmpty { throw ValidationError.URLRequired }
            }
            
            if newEntry.accountName.isEmpty { throw ValidationError.AccountNameRequired }
            if newEntry.issuer.isEmpty { throw ValidationError.IssuerRequired }
            if newEntry.secret.isEmpty { throw ValidationError.SecretRequired }
            
            // Try to calculate the OTP to make sure the data is valid
            _ = try newEntry.getOtp()
            
            try await keychain.store(otp: self.newEntry)
            
            await refresh?()
            
            DispatchQueue.main.async { dismiss() }
        }
    }
    
    var manualAddForm: some View {
        Form {
            Section {
                OVTextField("Account Name", text: $newEntry.accountName, placeholder: "Gold Account")
                OVTextField("Issuer", text: $newEntry.issuer, placeholder: "Acme Corp")
                HStack {
                    OVTextField("Domain", text: $newEntry.domainName, placeholder: "example.com")
#if !os(macOS)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
#endif
                    DomainIcon(otp: newEntry)
                }
            } footer: {
                Text("""
                     Logos provided by [Logo.dev](https://logo.dev)
                     
                     To prevent requests being made to [Logo.dev](https://logo.dev), you can either remove the Domain from this OTPs configuration, or disable Domain Icons in Settings.
                     """)
            }
            
            OVTextField("Secret", text: $newEntry.secret, placeholder: "ABCDEFGHIJKLMNOP")
                .onChange(of: newEntry.secret) {
                    newEntry.secret = newEntry.secret
                        .replacingOccurrences(of: " ", with: "")
                        .uppercased()
                }
            
            Section {
                DisclosureGroup("Advanced") {
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
                    
                    switch newEntry.type {
                    case .totp:
                        Picker("Period", selection: $newEntry.period) {
                            Text("15 Seconds").tag(15)
                            Text("30 Seconds").tag(30)
                            Text("45 Seconds").tag(45)
                            Text("60 Seconds").tag(60)
                        }
                    case .hotp:
                        // NOTSUPPORTED: HOTP Codes not supported
                        EmptyView()
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
    
    var fromUrlForm: some View {
        Form {
            Section {
                OVTextField("URL", text: $url, placeholder: "otpauth://totp/Example:alice@example.com?secret=ABCDEFGHIJKLMNOP")
#if !os(macOS)
                    .textInputAutocapitalization(.never)
                    .textContentType(.URL)
#endif
            }
            
            Section("Calculated") {
                LabeledContent("Account Name", value: newEntry.accountName)
                LabeledContent("Issuer", value: newEntry.issuer)
                LabeledContent("Secret", value: newEntry.secret)
                LabeledContent("Algorithm", value: newEntry.algorithm.rawValue)
                LabeledContent("Length", value: newEntry.digits.description)
                LabeledContent("Period", value: "\(newEntry.period)s")
            }
        }
        .formStyle(.grouped)
        .onChange(of: url) {
            if let url = URL(string: url),
               let otp = try? Otp.from(url: url) {
                self.newEntry = otp
            } else {
                self.newEntry = .blank()
            }
        }
    }
    
    var body: some View {
        VStack {
            Picker("Type", selection: $tab) {
                Text("Manual").tag(PageType.manual)
                Text("From URL").tag(PageType.byUrl)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding([.horizontal, .top])
            
            switch tab {
            case .byUrl:
                fromUrlForm
                    .transition(.opacity)
            case .manual:
                manualAddForm
                    .transition(.opacity)
            }
            
            Spacer()
            
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
        .animation(.easeInOut, value: tab)
        .navigationTitle("New OTP")
#if !os(macOS)
        .background(Color(uiColor: .systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                AsyncButton("Save", action: save)
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
