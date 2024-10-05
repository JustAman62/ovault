import SwiftUI
import SwiftData
import Models

struct ContentView: View {
    @State private var isOtpScanPresented: Bool = false
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.notifier) private var notifier
    @Environment(\.keychain) private var keychain
    
    @Query private var items: [OtpMetadata]

    var body: some View {
        NavigationStack {
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
                ForEach(items) { item in
                    OtpEntryView(otp: item)
                    #if os(macOS)
                    .padding()
                    #else
                    .padding(.top, 2)
                    .padding(.bottom, 6)
                    .labelStyle(.titleAndIcon)
                    #endif
                }
            }
            .toolbar {
                ToolbarItem {
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
            }
            .navigationTitle("OVault")
            .onOpenURL { url in
                notifier.execute {
                    let (otp, secret) = try OtpMetadata.from(url: url)
                    try keychain.storeSecret(metadata: otp, secret: secret)
                    modelContext.insert(otp)
                    try modelContext.save()
                }
            }
            #if !os(macOS)
            .sheet(isPresented: $isOtpScanPresented) {
                OtpQrScannerView()
                    .withNotifierSupport()
            }
            #endif
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

#if DEBUG
#Preview("With items") {
    ContentView()
        .previewEnvironment()
}

#Preview("Empty") {
    ContentView()
        .previewEnvironment(withData: false)
}
#endif
