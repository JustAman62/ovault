import SwiftUI
import Models

struct OtpEntryView: View {
    var otp: Otp
    
    @State private var calculated: String = ""
    @State private var expiresIn: Double = 0.0
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.notifier) private var notifier
    @Environment(\.keychain) private var keychain
    @Environment(\.refresh) private var refresh
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                HStack {
                    DomainIcon(otp: otp)

                    Text(otp.issuer)
                        .bold()
                }

                Spacer()

                Text(otp.accountName)
                    .font(.caption)
                
                Menu {
                    menu()
                } label: {
                    Label("Menu", systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                        .contentShape(.circle)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 30, height: 30)
            }
            
            HStack {
                Text(calculated)
                    .font(.title)
                    .textSelection(.enabled)
                    .animation(.easeInOut, value: calculated)
                
                Spacer()
                CopyButton("Copy", value: calculated)
                    .font(.caption)
#if os(macOS)
                    .controlSize(.large)
#endif
            }
            
            TimelineView(.periodic(from: otp.lastExpiryDate, by: Double(otp.period))) { _ in
                ProgressView(timerInterval: otp.lastExpiryDate...otp.nextExpiryDate)
                    .progressViewStyle(.linear)
                    .labelsHidden()
                    .onChange(of: otp.timeStep, initial: true) {
                        notifier.execute {
                            try calculated = otp.getOtp()
                        }
                    }
            }
        }
        .contentShape(.rect)
        .contextMenu(
            ContextMenu {
                menu()
            }
        )
        .swipeActions(edge: .trailing) {
            menu()
        }
    }
    
    @ViewBuilder
    private func menu() -> some View {
        NavigationLink {
            EditOtpEntryView(otp: otp)
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        
        CopyButton("Copy", value: calculated)
        
        AsyncButton("Delete", systemImage: "trash", role: .destructive) {
            await notifier.execute {
                try await keychain.delete(otp: otp)
                await refresh?()
                DispatchQueue.main.async { dismiss() }
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        OtpEntryView(otp: .testTotp15sec)
    }
    .previewEnvironment()
}
#endif
