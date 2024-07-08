import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.notifier) private var notifier
    
    @Query private var items: [OtpEntry]

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
                        
                        Button("Scan QR Code", systemImage: "qrcode.viewfinder") {
                            // TODO: Implement in-app scanner
                        }
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
                        
                        Button("Scan QR Code", systemImage: "qrcode.viewfinder") {
                            // TODO: Implement in-app scanner
                        }
                    } label: {
                        Label("New OTP", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("OVault")
            .onOpenURL { url in
                notifier.execute {
                    let entry = try OtpEntry.from(url: url)
                    modelContext.insert(entry)
                    try modelContext.save()
                }
            }
        }
    }
}

#if DEBUG
#Preview("With items") {
    ContentView()
        .previewEnvironment()
}

#Preview("Empty") {
    ContentView()
}
#endif
