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

    @State private var remainingFraction = 1.0;
    @State private var calculated: String = ""
    
    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    init(
        otp: Otp,
        timer: Publishers.Autoconnect<Timer.TimerPublisher>
    ) {
        self.otp = otp
        self.timer = timer
        
        self.updateRemaining()
    }
    
    private func updateRemaining() {
        remainingFraction = otp.intervalToNextExpiry / Double(otp.period)
    }
    
    private func updateCalculated() {
        notifier.execute {
            print("getting otp2 \(otp.id) \(otp.timeStep)")
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
            .onChange(of: otp.timeStep, initial: true) {
                self.updateCalculated()
            }
            
            GeometryReader { geo in
                // Use a custom progress bar instead of the usual `ProgressView`, because the `ProgressView(timerInterval:)` view uses loads of CPU
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(.accent)
                    .frame(
                        width: geo.size.width * remainingFraction,
                        height: 6)
                    .padding(.bottom)
                    .animation(.linear(duration: 1), value: remainingFraction)
                    .onReceive(timer) { _ in
                        updateRemaining()
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
        OtpEntryView(
            otp: .testTotp15sec,
            timer: Timer
                .publish(every: 1, on: .main, in: .common)
                .autoconnect()
        )
    }
    .previewEnvironment()
}
#endif
