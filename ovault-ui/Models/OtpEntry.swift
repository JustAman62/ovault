import Foundation
import SwiftData

@Model
final class OtpEntry {
    /// The provider this credential is associated with.
    var issuer: String
    /// The name of the account (or any useful identifier) which this credential is associated with.
    var accountName: String?
    
    /// The hashing algorithm to generate the OTP with. Valid Values: `SHA1` (Default), `SHA256`, `SHA512`.
    var algorithm: HashAlgorithm
    /// The number of digits in the OTP. Valid Values: `6` (Default), `7`, `8`.
    var digits: Int
    
    /// Arbitrary value encoded in Base32.
    var secret: String
    
    var type: OtpType
    
    /// The initial counter value, only used for `OtpType.hotp` credentials.
    var counter: Int64
    /// The period parameter for `OtpType.totp` credentials, in seconds. Defaults to 30 seconds.
    var period: Int
    
    init(issuer: String, accountName: String? = nil, algorithm: HashAlgorithm, digits: Int, secret: String, type: OtpType, counter: Int64, period: Int) {
        self.issuer = issuer
        self.accountName = accountName
        self.algorithm = algorithm
        self.digits = digits
        self.secret = secret
        self.type = type
        self.counter = counter
        self.period = period
    }
}

enum OtpType: String, Codable {
    case totp, hotp
}

enum HashAlgorithm: String, Codable {
    case SHA1, SHA256, SHA512
}
