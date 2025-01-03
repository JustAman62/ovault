import SwiftUI

extension Scene {
    func floatWindowIfSupportedAndEnabled() -> some Scene {
        let floatWindow = UserDefaults.appGroup?.floatWindow ?? false

        if #available(macOS 15.0, *) {
#if os(macOS)
            return self.windowLevel(floatWindow ? .floating : .automatic)
#else
            return self
#endif
        } else {
            return self
        }
    }
}
