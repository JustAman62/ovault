import Foundation
import OSLog

public extension UserDefaults {
    static var appGroup: UserDefaults? {
#if MAC_DIRECT_DISTRIBUTION
        UserDefaults(suiteName: "KED4M385SL.net.ovault")
#else
        UserDefaults(suiteName: "group.net.ovault")
#endif
    }
    
    var widgetShowsOpenInAppButton: Bool {
        get {
            self.bool(forKey: "widgetShowsOpenInAppButton")
        }
        set {
            self.set(newValue, forKey: "widgetShowsOpenInAppButton")
        }
    }

    var iconsEnabled: Bool {
        get {
            self.bool(forKey: "iconsEnabled")
        }
        set {
            self.set(newValue, forKey: "iconsEnabled")
        }
    }

    var floatWindow: Bool {
        get {
            self.bool(forKey: "floatWindow")
        }
        set {
            self.set(newValue, forKey: "floatWindow")
        }
    }
}
