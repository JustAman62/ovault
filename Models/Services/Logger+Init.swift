import Foundation
import OSLog

public extension Logger {
    public init<Subject>(_ subject: Subject) {
        self.init(subsystem: Bundle.main.bundleIdentifier ?? "Roam.Andy", category: String(describing: subject))
    }
    
    public init(_ category: String) {
        self.init(subsystem: Bundle.main.bundleIdentifier ?? "Roam.Andy", category: category)
    }
}
