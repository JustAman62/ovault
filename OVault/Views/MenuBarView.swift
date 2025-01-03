import SwiftUI
import Models

struct MenuBarView: View {
    @Environment(\.keychain) private var keychain
    @Environment(\.openWindow) private var openWindow
    
    @State private var items: [Otp]? = nil
    
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
                } label: {
                    Label("Open OVault", systemImage: "arrow.up.forward.app.fill")
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom)

                if let items = items {
                    ForEach(items) { item in
                        OtpEntryView(otp: item)
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
