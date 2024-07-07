import Foundation
import SwiftUI
import SwiftData

extension View {
    @MainActor
    func previewEnvironment() -> some View {
        return self
            .modelContainer(
                for: OtpEntry.self,
                inMemory: true,
                onSetup: { res in
                    setupData(container: try! res.get())
                }
            )
    }
    
    @MainActor
    private func setupData(container: ModelContainer) {
        let ctx = container.mainContext
        ctx.insert(OtpEntry(issuer: "Issuer", algorithm: .SHA1, digits: 6, secret: "somesecret", type: .totp, counter: 0, period: 30))
        try! ctx.save()
    }
}
