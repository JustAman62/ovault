import SwiftUI
import Models

#if os(macOS)
struct MenuBarView: View {
    @Environment(\.keychain) private var keychain
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss
    
    @State private var items: [Otp]? = nil
    
    private let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    private func load() async {
        do {
            self.items = try await keychain.getAll()
        } catch {
            self.items = nil
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Button {
                    openWindow(id: "otp-list")
                    NSApp.activate()
                    dismiss()
                } label: {
                    Label("Open OVault", systemImage: "arrow.up.forward.app.fill")
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom)

                if let items = items {
                    ForEach(items) { item in
                        OtpEntryView(otp: item, timer: timer)
                    }
                }
            }
            .padding()
        }
        .task {
            await load()
        }
    }
}

#if DEBUG
#Preview {
    MenuBarView()
        .previewEnvironment()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
#endif
#endif
