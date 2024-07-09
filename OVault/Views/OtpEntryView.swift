import SwiftUI
import Models

struct OtpEntryView: View {
    @Bindable var otp: OtpMetadata
    
    @State private var calculated: String = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.notifier) private var notifier
    
    var expiresIn: Double { Date().timeIntervalSince1970.truncatingRemainder(dividingBy: Double(otp.period))
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text(otp.issuer)
                    .bold()
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
                .frame(width: 30)
            }
            
            HStack {
                Text(calculated)
                    .font(.title)
                    .textSelection(.enabled)
                    
                Spacer()
                CopyButton("Copy", value: calculated)
                    .font(.caption)
#if os(macOS)
                    .controlSize(.large)
#endif
            }
            
            TimelineView(.periodic(from: Date(), by: 0.05)) { _ in
                ProgressView(value: Double(otp.expiresIn), total: Double(otp.period))
                    .progressViewStyle(.linear)
                .onChange(of: otp.timeStep, initial: true) {
                    calculated = otp.getOtp()
                }
                .onChange(of: otp.counter, initial: true) {
                    calculated = otp.getOtp()
                }
            }
        }
        .contentShape(.rect)
        .contextMenu(
            ContextMenu {
                menu()
            }
        )
    }
    
    @ViewBuilder
    private func menu() -> some View {
        NavigationLink {
            EditOtpEntryView(otp: otp)
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        
        Button("Delete", systemImage: "trash", role: .destructive) {
            notifier.execute {
                modelContext.delete(otp)
                try modelContext.save()
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
}
#endif
