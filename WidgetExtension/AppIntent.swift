import WidgetKit
import AppIntents
import Models
import SwiftUI

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Two OTPs" }
    static var description: IntentDescription { "Shows any two OTPs, allowing you to see and copy them." }

    @Parameter(title: "Selected OTPs", default: [], size: 2)
    var entities: [OtpEntity]
    
    @Parameter(title: "Selected OTP to Show", default: nil, inputConnectionBehavior: .connectToPreviousIntentResult)
    var selected: String?
}

struct OtpEntity: AppEntity, Identifiable {
    var id: String
    
    var accountName: String
    var issuer: String
    
    // Visual representation e.g. in the dropdown, when selecting the entity.
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(issuer) - \(accountName)")
    }
    
    // Placeholder whenever it needs to present your entity’s type onscreen.
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "OTP"
    
    static var defaultQuery = OtpQuery()
}

struct OtpQuery: EntityQuery {
    // The options presented to the user
    func suggestedEntities() async throws -> [OtpEntity] {
        try await Keychain.shared.getAll().map({ OtpEntity(id: $0.id.uuidString, accountName: $0.accountName, issuer: $0.issuer) })
    }
    
    // Fetch the selected entities
    func entities(for identifiers: [String]) async throws -> [OtpEntity] {
        let entities = try await suggestedEntities()
        return entities.filter({ identifiers.contains($0.id) })
    }
}

struct GenerateOtpAppIntent: AppIntent {
    static var title: LocalizedStringResource { "Generate OTP" }
    static var description: IntentDescription { "Generates an OTP for the specified ID" }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    
    @Parameter(title: "Selected OTP", default: "")
    var id: String
    
    init(id: String) {
        self.id = id
    }
    
    init() { }
    
    func perform() async throws -> some IntentResult & OpensIntent {
        let otp = try await Keychain.shared.get(id: id)

        UserDefaults.standard.set(otp.id.uuidString, forKey: "WidgetShowCodeForId")
        UserDefaults.standard.set(otp.nextExpiryDate, forKey: "WidgetShowCodeExpiryDate")

        return .result()
    }
}
