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
    func get(id: String) async throws -> Otp
    func getAll() async throws -> [Otp]
    func delete(otp: Otp) async throws -> Void
}

public actor Keychain: KeychainProtocol {
    #if DEBUG
    public static var shared: KeychainProtocol = FakeKeychain(withData: true)
    #else
    public static var shared: KeychainProtocol = Keychain()
    #endif
    
    public func store(otp: Otp) throws {
        let addQuery = try createAddQuery(otp: otp)
        
        let status = SecItemAdd(addQuery, nil)
        guard status == errSecSuccess else { throw KeychainError.addFailure(status) }
    }
    
    public func update(otp: Otp) throws {
        let findQuery = createFindQuery(id: otp.id.uuidString)
        let updateQuery = try createUpdateQuery(otp: otp)
        
        let status = SecItemUpdate(findQuery, updateQuery)
        guard status == errSecSuccess else { throw KeychainError.addFailure(status) }
    }
    
    public func getAll() async throws -> [Otp] {
        let getAllQuery = createGetAllQuery()
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(getAllQuery as CFDictionary, &result)
        if (status == errSecItemNotFound) { return [] }
        guard status == errSecSuccess else { throw KeychainError.fetchFailure(status) }
        
        // Result is an array of dictionaries, where each dictionary is all the response attributes
        guard let results = result as? [[String : Any]] else { throw KeychainError.fetchUnexpectedResult }
        
        var otps: [Otp] = []
        for result in results {
            let otp = try await convertResultToOtp(result)
            otps.append(otp)
        }

        return otps.sorted(by: { $0.accountName.uppercased() < $1.accountName.uppercased() })
    }
    
    public func get(id: String) async throws -> Otp {
        var getQuery = createFindQuery(id: id) as! [String: Any]
        getQuery.updateValue(true, forKey: kSecReturnAttributes as String)
        getQuery.updateValue(true, forKey: kSecReturnData as String)
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(getQuery as CFDictionary, &result)
        guard status == errSecSuccess else { throw KeychainError.fetchFailure(status) }
        
        // Result is an array of dictionaries, where each dictionary is all the response attributes
        guard let result = result as? [String : Any] else { throw KeychainError.fetchUnexpectedResult }

        return try await convertResultToOtp(result)
    }
    
    public func delete(otp: Otp) throws {
        let findQuery = createFindQuery(id: otp.id.uuidString)
        
        let status = SecItemDelete(findQuery)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.fetchFailure(status) }
    }
    
    func createFindQuery(id: String) -> CFDictionary {
        let name = "net.ovault.otp.\(id)"
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
    
    func convertResultToOtp(_ result: [String : Any]) async throws -> Otp {
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
        
        let otp = Otp(from: data, id: id, secret: secret)
        
        await otp.loadDomainIcon()
        
        return otp
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
        for otp in otps {
            await otp.loadDomainIcon()
        }

        return otps.sorted(by: { $0.accountName.uppercased() < $1.accountName.uppercased() })
    }
    
    public func get(id: String) async throws -> Otp {
        guard let otp = otps.first(where: { $0.id.uuidString == id }) else { throw KeychainError.fetchFailure(-1) }
        await otp.loadDomainIcon()

        return otp
    }
    
    public func delete(otp: Otp) async throws {
        let otpToDelete = otps.firstIndex(where: { $0.id == otp.id })!
        otps.remove(at: otpToDelete)
    }
}
#endif

public struct KeychainKey: EnvironmentKey {
    public static let defaultValue: KeychainProtocol = Keychain.shared
}

extension EnvironmentValues {
    public var keychain: KeychainProtocol {
        get { self[KeychainKey.self] }
        set { self[KeychainKey.self] = newValue }
    }
}
