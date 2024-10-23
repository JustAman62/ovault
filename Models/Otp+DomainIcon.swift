import Foundation
import SwiftUI

extension Otp {
    public func loadDomainIcon() async -> Void {
        self.domainIcon = nil

        if self.domainName.isEmpty { return }
        
        guard let userDefaults = UserDefaults(suiteName: "group.net.ovault") else { return }
        let iconsEnabled = userDefaults.bool(forKey: "iconsEnabled")
        if !iconsEnabled { return }
        
        guard let url = URL(string: "https://img.logo.dev/\(self.domainName)?format=png&token=pk_TM6KzUJ7SBWjyqpGWdWLmg") else { return }
        
        do {
            let (data, res) = try await URLSession.shared.data(from: url)

            if res.mimeType != "image/png" { return }

#if canImport(UIKit)
            guard let uiImage = UIImage(data: data) else { return }
            self.domainIcon = Image(uiImage: uiImage)
#elseif canImport(AppKit)
            guard let nsImage = NSImage(data: data) else { return }
            self.domainIcon = Image(nsImage: nsImage)
#endif
        } catch {
            return
        }
    }
}
