import Foundation
import SwiftUI
import SwiftData
import Models

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
            .withNotifierSupport()
    }
    
    @MainActor
    private func setupData(container: ModelContainer) {
        let ctx = container.mainContext
        ctx.insert(OtpEntry.testTotp15sec)
        ctx.insert(OtpEntry.testTotp30sec)
        ctx.insert(OtpEntry.testTotp60sec)
        try! ctx.save()
    }
}
