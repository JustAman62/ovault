import Foundation
import SwiftUI
import Models

#if DEBUG
extension View {
    @MainActor
    func previewEnvironment(withData: Bool = true) -> some View {
        return self
            .withNotifierSupport()
            .environment(\.keychain, FakeKeychain(withData: withData))
    }
}
#endif
