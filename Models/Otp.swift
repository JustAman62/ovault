import Foundation
import SwiftData
import SwiftUI

@Observable
public final class Otp: Identifiable {
    public var id: UUID
    
    /// The provider this credential is associated with.
    public var issuer: String
    /// The name of the account (or any useful identifier) which this credential is associated with.
    public var accountName: String
    /// The doamin name the OTP is used for. This is used to populate the logo associated with the OTP. This is allows to be empty.
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
    
    public var domainIcon: Image?
    
    public init(id: UUID, issuer: String, accountName: String, domainName: String, algorithm: HashAlgorithm, digits: Int, secret: String, period: Int, type: OtpType = .totp, counter: Int64 = 0) {
        self.id = id
        self.issuer = issuer
        self.accountName = accountName
        self.domainName = domainName
        self.algorithm = algorithm
        self.digits = digits
        self.secret = secret
        self.type = type
        self.counter = counter
        self.period = period
    }
    
    public func clone() -> Otp {
        return Otp(
            id: self.id,
            issuer: self.issuer,
            accountName: self.accountName,
            domainName: self.domainName,
            algorithm: self.algorithm,
            digits: self.digits,
            secret: self.secret,
            period: self.period,
            type: self.type,
            counter: self.counter
        )
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
    
    public var intervalToNextExpiry: TimeInterval {
        (Date.now.timeIntervalSince(self.nextExpiryDate) * -1).rounded(.up)
    }
}

public enum OtpType: String, CaseIterable, Hashable, Codable {
    case totp
    case hotp
}

public enum HashAlgorithm: String, CaseIterable, Identifiable, Hashable, Codable {
    case SHA1, SHA256, SHA512
    public var id: String { self.rawValue }
}
