import Foundation
import SwiftData
import SwiftUI

public final class Otp: Identifiable {
    public var id: UUID
    
    /// The provider this credential is associated with.
    public var issuer: String
    /// The name of the account (or any useful identifier) which this credential is associated with.
    public var accountName: String
    /// The doamin name the OTP is used for. This is used to populate the logo associated with the OTP.
    public var domainName: String
    
    /// The hashing algorithm to generate the OTP with. Valid Values: `SHA1` (Default), `SHA256`, `SHA512`.
    public var algorithm: HashAlgorithm
    /// The number of digits in the OTP. Valid Values: `6` (Default), `7`, `8`.
    public var digits: Int
    
    /// Base32-encoded secret string.
    public var secret: String
    
    /// Whether this is a TOTP or HOTP OTP.
    public var type: OtpType
    
    /// The initial counter value, only used for `OtpType.hotp` credentials.
    public var counter: Int64
    /// The period parameter for `OtpType.totp` credentials, in seconds. Defaults to 30 seconds.
    public var period: Int
    
    public init(id: UUID, issuer: String, accountName: String, domainName: String, algorithm: HashAlgorithm, digits: Int, secret: String, period: Int) {
        self.id = id
        self.issuer = issuer
        self.accountName = accountName
        self.domainName = domainName
        self.algorithm = algorithm
        self.digits = digits
        self.secret = secret
        self.type = .totp
        self.counter = 0
        self.period = period
    }
}

extension Otp {
    public var timeStep: Int64 { Int64(Date().timeIntervalSince1970) / Int64(self.period) }
    
    public var lastExpiryDate: Date {
        Date(timeIntervalSince1970: Double(self.timeStep * Int64(self.period)))
    }

    public var nextExpiryDate: Date {
        Date(timeIntervalSince1970: Double((self.timeStep + 1) * Int64(self.period)))
    }
}

extension Otp {
    public var imageUrl: URL { URL(string: "https://img.logo.dev/\(self.domainName)?format=png&token=pk_TM6KzUJ7SBWjyqpGWdWLmg")! }
}

public enum OtpType: String, CaseIterable, Hashable, Codable {
    case totp
    case hotp
}

public enum HashAlgorithm: String, CaseIterable, Identifiable, Hashable, Codable {
    case SHA1, SHA256, SHA512
    public var id: String { self.rawValue }
}
