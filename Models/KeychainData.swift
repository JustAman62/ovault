import Foundation

internal struct KeychainData: Codable {
    /// The provider this credential is associated with.
    public var issuer: String
    /// The name of the account (or any useful identifier) which this credential is associated with.
    public var accountName: String
    public var domainName: String
    
    /// The hashing algorithm to generate the OTP with. Valid Values: `SHA1` (Default), `SHA256`, `SHA512`.
    public var algorithm: HashAlgorithm
    /// The number of digits in the OTP. Valid Values: `6` (Default), `7`, `8`.
    public var digits: Int
    
    public var type: OtpType
    
    /// The initial counter value, only used for `OtpType.hotp` credentials.
    public var counter: Int64
    /// The period parameter for `OtpType.totp` credentials, in seconds. Defaults to 30 seconds.
    public var period: Int
}

extension KeychainData {
    init(from otp: Otp) {
        self.init(
            issuer: otp.issuer,
            accountName: otp.accountName,
            domainName: otp.domainName,
            algorithm: otp.algorithm,
            digits: otp.digits,
            type: otp.type,
            counter: otp.counter,
            period: otp.period
        )
    }
}

extension Otp {
    convenience init(from data: KeychainData, id: UUID, secret: String) {
        self.init(id: id, issuer: data.issuer, accountName: data.accountName, domainName: data.domainName, algorithm: data.algorithm, digits: data.digits, secret: secret, period: data.period)
    }
}
