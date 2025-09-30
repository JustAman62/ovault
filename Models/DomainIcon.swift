import SwiftUI


public struct DomainIcon: View {
    private var otp: Otp

    private let size: CGFloat = 30
    
    public init(otp: Otp) {
        self.otp = otp
    }
    
    @State var previousTask: Task<Void, Never>?

    public var body: some View {
        Group {
            if let image = otp.domainIcon {
                image
                    .resizable()
                    .frame(width: size, height: size)
                    .clipShape(.circle)
            } else {
                Text(otp.issuer.prefix(1).uppercased())
                    .frame(width: size, height: size)
                    .background(.white)
                    .foregroundStyle(.black)
                    .clipShape(.circle)
            }
        }
        .onChange(of: otp.domainName, initial: true) {
            previousTask?.cancel()
            previousTask = Task {
                await otp.loadDomainIcon()
            }
        }
    }
}

#if DEBUG
#Preview("Not Loaded") {
    DomainIcon(otp: .testTotp30sec)
        .task {
            Otp.testTotp30sec.domainIcon = nil
        }
}

#Preview("Loaded") {
    DomainIcon(otp: .testTotp30sec)
}
#endif
