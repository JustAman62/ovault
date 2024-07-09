import Foundation
import SwiftUI
import SwiftData
import Models

extension View {
    @MainActor
    func previewEnvironment(withData: Bool = true) -> some View {
        return self
            .modelContainer(
                for: OtpMetadata.self,
                inMemory: true,
                onSetup: { res in
                    if withData {
                        setupData(container: try! res.get())
                    }
                }
            )
            .withNotifierSupport()
    }
    
    @MainActor
    private func setupData(container: ModelContainer) {
        let ctx = container.mainContext
        ctx.insert(OtpMetadata.testTotp15sec)
        ctx.insert(OtpMetadata.testTotp30sec)
        ctx.insert(OtpMetadata.testTotp60sec)
        try! ctx.save()
    }
}
