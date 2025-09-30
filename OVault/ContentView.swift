import SwiftUI
import Models
import OSLog

struct ContentView: View {
    @State private var isOtpScanPresented: Bool = false
    @State private var isSettingsPresented: Bool = false
    @State private var items: [Otp]? = nil
    
    @Environment(\.notifier) private var notifier
    @Environment(\.keychain) private var keychain

    private var logger: Logger = .init(ContentView.self)
    
    private func load() async {
        await notifier.execute {
            self.items = try await keychain.getAll()
        }
    }
    
    @ViewBuilder private func otpList(items: [Otp]) -> some View {
        if items.count == 0 {
            ContentUnavailableView(
                label: {
                    Label("No OTPs Registered", systemImage: "list.bullet")
                },
                description: {
                    Text("Add OTPs by scanning their QR codes, or adding it manually")
                },
                actions: {
                    NavigationLink {
                        AddOtpEntryView()
                    } label: {
                        Label("Add Manually", systemImage: "plus")
                    }
                    
#if !os(macOS)
                    Button("Scan QR Code", systemImage: "qrcode.viewfinder") {
                        isOtpScanPresented = true
                    }
#endif
                })
        }
        
        List {
            Section {
                ForEach(items) { item in
                    OtpEntryView(otp: item)
                        .refreshable {
                            await load()
                        }
#if os(macOS)
                        .padding()
#else
                        .padding(.top, 2)
                        .padding(.bottom, 6)
                        .labelStyle(.titleAndIcon)
#endif
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                switch items {
                case .none:
                    ProgressView("Loading OTPs")
                case .some(let otps):
                    otpList(items: otps)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        NavigationLink {
                            AddOtpEntryView()
                        } label: {
                            Label("Manual", systemImage: "plus")
                        }
                        
#if !os(macOS)
                        Button("Scan QR Code", systemImage: "qrcode.viewfinder") {
                            isOtpScanPresented = true
                        }
#endif
                    } label: {
                        Label("New OTP", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .automatic) {
#if os(macOS)
                    SettingsLink()
#else
                    Button("Settings", systemImage: "gear") {
                        isSettingsPresented.toggle()
                    }
#endif
                }
            }
            .navigationTitle("OVault")
            .onOpenURL { url in
                Task {
                    await notifier.execute {
                        switch url.scheme {
                        case "otpauth", "ovault-otpauth":
                            let otp = try Otp.from(url: url)
                            try await keychain.store(otp: otp)
                            await load()
                            break
                        default:
                            self.logger.info("URL opened with scheme \(url.scheme ?? "Unknown"), ignoring")
                            break
                        }
                    }
                }
            }
            .task {
                await load()
            }
#if !os(macOS)
            .sheet(isPresented: $isOtpScanPresented) {
                OtpQrScannerView()
                    .withNotifierSupport()
            }
#endif
        }
        .scrollDismissesKeyboard(.interactively)
        .refreshable {
            await load()
        }
        .sheet(isPresented: $isSettingsPresented) {
            NavigationStack {
                SettingsView()
                    .navigationTitle("Settings")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Close") {
                                isSettingsPresented.toggle()
                            }
                        }
                    }
            }
        }
    }
}

#if DEBUG
#Preview("With items") {
    ContentView()
        .previewEnvironment()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

#Preview("Empty") {
    ContentView()
        .previewEnvironment(withData: false)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
#endif
