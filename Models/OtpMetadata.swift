import Foundation
import SwiftData
import SwiftUI

@Model
public final class OtpMetadata: Identifiable {
    public var id: UUID
    
    /// The provider this credential is associated with.
    public var issuer: String
    /// The name of the account (or any useful identifier) which this credential is associated with.
    public var accountName: String
    
    /// The hashing algorithm to generate the OTP with. Valid Values: `SHA1` (Default), `SHA256`, `SHA512`.
    public var algorithm: HashAlgorithm
    /// The number of digits in the OTP. Valid Values: `6` (Default), `7`, `8`.
    public var digits: Int
    
    // TODO: Store this secret in Keychain, and just store a path/identifier here instead
    /// Arbitrary value encoded in Base32.
    public var secret: String
    
    public var type: OtpType
    
    /// The initial counter value, only used for `OtpType.hotp` credentials.
    public var counter: Int64
    /// The period parameter for `OtpType.totp` credentials, in seconds. Defaults to 30 seconds.
    public var period: Int
    
    public init(id: UUID, issuer: String, accountName: String, algorithm: HashAlgorithm, digits: Int, secret: String, type: OtpType, counter: Int64, period: Int) {
        self.id = id
        self.issuer = issuer
        self.accountName = accountName
        self.algorithm = algorithm
        self.digits = digits
        self.secret = secret
        self.type = type
        self.counter = counter
        self.period = period
    }
    
    public var timeStep: Int64 { Int64(Date().timeIntervalSince1970) / Int64(self.period) }
    public var expiresIn: Double {
        withAnimation {
            Double(self.period) - Date().timeIntervalSince1970.truncatingRemainder(dividingBy: Double(self.period))
        }
    }
}

public enum OtpType: String, CaseIterable, Hashable, Codable {
    case totp, hotp
}

public enum HashAlgorithm: String, CaseIterable, Identifiable, Hashable, Codable {
    case SHA1, SHA256, SHA512
    public var id: String { self.rawValue }
}
