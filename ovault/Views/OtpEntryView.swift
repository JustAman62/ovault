import SwiftUI

struct OtpEntryView: View {
    @Bindable var otp: OtpEntry
    
    @State private var calculated: String = ""
    
    var expiresIn: Double { Date().timeIntervalSince1970.truncatingRemainder(dividingBy: Double(otp.period))
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .lastTextBaseline) {
                Text(otp.issuer)
                    .bold()
                Spacer()
                if let accountName = otp.accountName {
                    Text(accountName)
                        .font(.caption)
                }
                
            }
            
            HStack {
                Text(calculated)
                    .font(.title)
                    .textSelection(.enabled)
                Spacer()
                CopyButton(value: calculated)
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
            }
        }
        .padding()
    }
}

#if DEBUG
#Preview {
    OtpEntryView(otp: .testTotp15sec)
}
#endif
