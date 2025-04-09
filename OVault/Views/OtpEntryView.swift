import SwiftUI
import Combine
import Models

struct OtpEntryView: View {
    var otp: Otp
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.notifier) private var notifier
    @Environment(\.keychain) private var keychain
    @Environment(\.refresh) private var refresh
    // The appearsActive environment key is only available after iOS18, so we use a compat key
    @Environment(\.appearsActiveCompat) private var appearsActive

    @State private var calculated: String = ""

    private var remainingFraction: Double {
        otp.intervalToNextExpiry / Double(otp.period)
    }

    init(
        otp: Otp
    ) {
        self.otp = otp
    }
    
    private func updateCalculated() {
        notifier.execute {
            calculated = try otp.getOtp()
        }
    }

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
            
            GeometryReader { geo in
                TimelineView(.animation(minimumInterval: 1, paused: !self.appearsActive)) { _ in
                    // Use a custom progress bar instead of the usual `ProgressView`, because the `ProgressView(timerInterval:)` view uses loads of CPU
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(self.appearsActive ? .accent : .gray)
                        .frame(
                            width: geo.size.width * remainingFraction,
                            height: 6)
                        .padding(.bottom)
                        .animation(.linear(duration: 1), value: remainingFraction)
                        .onChange(of: otp.timeStep, initial: true) {
                            self.updateCalculated()
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
