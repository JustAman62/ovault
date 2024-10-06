import Foundation
import SwiftUI

enum KeychainError: Error, LocalizedError {
    case addFailure(_ status: OSStatus)
    case fetchFailure(_ status: OSStatus)
    case unexpectedData(_ description: String)
    case fetchUnexpectedResult
    
    var errorDescription: String? {
        switch self {
        case .addFailure(let status): "Failed to save the secret in the Keychain: \(status): \(getStatusDescription(status))"
        case .fetchFailure(let status): "Failed to fetch the secret from the Keychain: \(status): \(getStatusDescription(status))"
        case .unexpectedData(let description): "Unexpected data found in Keychain: \(description)"
        case .fetchUnexpectedResult: "Unexpected result returned from the Keychain"
        }
    }
    
    private func getStatusDescription(_ status: OSStatus) -> String {
        return SecCopyErrorMessageString(status, nil) as? String ?? "Unknown"
    }
}

public protocol KeychainProtocol {
    func store(otp: Otp) async throws -> Void
    func update(otp: Otp) async throws -> Void
    func getAll() async throws -> [Otp]
    func delete(otp: Otp) async throws -> Void
}

public actor Keychain: KeychainProtocol {
    
    public func store(otp: Otp) throws {
        let addQuery = try createAddQuery(otp: otp)
        
        let status = SecItemAdd(addQuery, nil)
        guard status == errSecSuccess else { throw KeychainError.addFailure(status) }
    }
    
    public func update(otp: Otp) throws {
        let findQuery = createFindQuery(otp: otp)
        let updateQuery = try createUpdateQuery(otp: otp)
        
        let status = SecItemUpdate(findQuery, updateQuery)
        guard status == errSecSuccess else { throw KeychainError.addFailure(status) }
    }
    
    public func getAll() throws -> [Otp] {
        let getAllQuery = createGetAllQuery()
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(getAllQuery as CFDictionary, &result)
        if (status == errSecItemNotFound) { return [] }
        guard status == errSecSuccess else { throw KeychainError.fetchFailure(status) }
        
        // Result is an array of dictionaries, where each dictionary is all the response attributes
        guard let results = result as? [[String : Any]] else { throw KeychainError.fetchUnexpectedResult }

        return try results.map({ try convertResultToOtp($0) })
    }
    
    public func delete(otp: Otp) throws {
        let findQuery = createFindQuery(otp: otp)
        
        let status = SecItemDelete(findQuery)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.fetchFailure(status) }
    }
    
    func createFindQuery(otp: Otp) -> CFDictionary {
        let name = "net.ovault.otp.\(otp.id.uuidString)"
        let service = "net.ovault.otp"
        return [kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: name,
                kSecAttrSynchronizable as String: kCFBooleanTrue as CFBoolean
        ] as CFDictionary
    }
    
    func createGetAllQuery() -> CFDictionary {
        let service = "net.ovault.otp"
        return [kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrSynchronizable as String: kCFBooleanTrue as CFBoolean,
                kSecMatchLimit as String: 50 as CFNumber,
                kSecReturnAttributes as String: true,
                kSecReturnData as String: true
        ] as CFDictionary
    }
    
    func createAddQuery(otp: Otp) throws -> CFDictionary {
        let name = "net.ovault.otp.\(otp.id.uuidString)"
        let service = "net.ovault.otp"
        let secretData = otp.secret.data(using: .utf8)!
        
        let data = KeychainData(from: otp)
        let encodedData = try JSONEncoder().encode(data)
        
        return [kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: name,
                kSecAttrService as String: service,
                kSecAttrSynchronizable as String: kCFBooleanTrue as CFBoolean,
                kSecAttrGeneric as String: encodedData as CFData,
                kSecValueData as String: secretData
        ] as CFDictionary
    }

    func createUpdateQuery(otp: Otp) throws -> CFDictionary {
        let name = "net.ovault.otp.\(otp.id.uuidString)"
        let service = "net.ovault.otp"
        let secretData = otp.secret.data(using: .utf8)!
        
        let data = KeychainData(from: otp)
        let encodedData = try JSONEncoder().encode(data)
        
        return [kSecAttrAccount as String: name,
                kSecAttrService as String: service,
                kSecAttrGeneric as String: encodedData as CFData,
                kSecValueData as String: secretData
        ] as CFDictionary
    }
    
    func convertResultToOtp(_ result: [String : Any]) throws -> Otp {
        let name = result[kSecAttrAccount as String] as! String
        guard let id = UUID(uuidString: name.replacing("net.ovault.otp.", with: "", maxReplacements: 1)) else {
            throw KeychainError.unexpectedData("Unable to parse ID from Name")
        }
        
        let secretData = result[kSecValueData as String] as! Data
        guard let secret = String(data: secretData, encoding: .utf8) else {
            throw KeychainError.unexpectedData("Unable to parse secret")
        }
        
        
        let encodedData = result[kSecAttrGeneric as String] as! Data
        let data = try JSONDecoder().decode(KeychainData.self, from: encodedData)
        
        return .init(from: data, id: id, secret: secret)
    }
}

#if DEBUG
public actor FakeKeychain: KeychainProtocol {
    private var otps: [Otp]

    public init(withData: Bool) {
        if withData {
            self.otps = [.testTotp15sec, .testTotp30sec, .testTotp60sec]
        } else {
            self.otps = []
        }
    }
    
    public func store(otp: Otp) async throws {
        otps.append(otp)
    }
    
    public func update(otp: Otp) async throws {
        let otpToUpdate = otps.firstIndex(where: { $0.id == otp.id })!
        otps.replaceSubrange(otpToUpdate...otpToUpdate, with: [otp])
    }
    
    public func getAll() async throws -> [Otp] {
        return otps
    }
    
    public func delete(otp: Otp) async throws {
        let otpToDelete = otps.firstIndex(where: { $0.id == otp.id })!
        otps.remove(at: otpToDelete)
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
