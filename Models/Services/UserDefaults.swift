import Foundation

public extension UserDefaults {
    static var appGroup: UserDefaults? {
        UserDefaults(suiteName: "group.net.ovault")
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
