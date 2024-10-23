import SwiftUI
import Models

struct DomainIcon: View {
    var otp: Otp
    
    @State var previousTask: Task<Void, Never>?

    var body: some View {
        Group {
            if let image = otp.domainIcon {
                image
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(.circle)
            } else {
                Text(otp.issuer.prefix(1).uppercased())
                    .frame(width: 30, height: 30)
                    .background(.white)
                    .foregroundStyle(.black)
                    .clipShape(.circle)
            }
        }
        .onChange(of: otp.domainName) {
            previousTask?.cancel()
            previousTask = Task {
                await otp.loadDomainIcon()
            }
        }
    }
}

#Preview("Not Loaded") {
    DomainIcon(otp: .testTotp30sec)
}

#Preview("Loaded") {
    DomainIcon(otp: .testTotp30sec)
        .task {
            await Otp.testTotp30sec.loadDomainIcon()
        }
}
