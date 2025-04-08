import SwiftUI

extension EnvironmentValues {
    var appearsActiveCompat: Bool {
        get {
            if #available(iOS 18.0, *) {
                self.appearsActive && self.scenePhase == .active
            } else {
                self.scenePhase == .active
            }
        }
    }
}
