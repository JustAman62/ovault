import Foundation
import SwiftUI

enum KeychainError: Error, LocalizedError {
    case addFailure(_ status: OSStatus)
    case fetchFailure(_ status: OSStatus)
    case fetchUnexpectedResult
    
    var errorDescription: String? {
        switch self {
        case .addFailure(let status): "Failed to save the secret in the Keychain: \(getStatusDescription(status))"
        case .fetchFailure(let status): "Failed to fetch the secret from the Keychain: \(getStatusDescription(status))"
        case .fetchUnexpectedResult: "Unexpected result returned from the Keychgain"
        }
    }
    
    private func getStatusDescription(_ status: OSStatus) -> String {
        return SecCopyErrorMessageString(status, nil) as? String ?? "Unknown"
    }
}

public protocol KeychainProtocol {
    func storeSecret(metadata: OtpMetadata, secret: String) throws -> Void
    func getOtp(metadata: OtpMetadata) throws -> String
}

public final class Keychain: KeychainProtocol {
    /// Stores the given `secret` in the Keychain, identified using information from the provided `metadata`
    public func storeSecret(metadata: OtpMetadata, secret: String) throws {
        let name = "\(metadata.accountName)-\(metadata.id.uuidString)"
        let addquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: name,
                                       kSecValueRef as String: secret]
        
        let status = SecItemAdd(addquery as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.addFailure(status) }
    }
    
    public func getOtp(metadata: OtpMetadata) throws -> String {
        let secret = try self.getSecret(metadata: metadata)
        return try metadata.getOtp(secret: secret)
    }
    
    /// Fetches the secret stored for the provided `metadata` from the Keychain
    private func getSecret(metadata: OtpMetadata) throws -> String {
        let name = "\(metadata.accountName)-\(metadata.id.uuidString)"
        
        let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: name,
                                       kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == errSecSuccess else { throw KeychainError.fetchFailure(status) }
        
        guard let existingItem = item as? [String : Any],
            let secretData = existingItem[kSecValueData as String] as? Data,
            let secret = String(data: secretData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.fetchUnexpectedResult
        }
        
        return secret
    }
}

#if DEBUG
public final class FakeKeychain: KeychainProtocol {
    public init() { }
    
    public func storeSecret(metadata: OtpMetadata, secret: String) throws {
        // Do Nothing
    }
    
    public func getOtp(metadata: OtpMetadata) throws -> String {
        return try metadata.getOtp(secret: "sharedsecret")
    }
}
#endif

public struct KeychainKey: EnvironmentKey {
    public static let defaultValue: KeychainProtocol = Keychain()
}

extension EnvironmentValues {
    public var keychain: KeychainProtocol {
        get { self[KeychainKey.self] }
        set { self[KeychainKey.self] = newValue }
    }
}
