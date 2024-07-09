import Foundation

#if DEBUG
public extension OtpEntry {
    static var testTotp30sec: OtpEntry = .init(
        issuer: "Test Issuer",
        accountName: "30sec Account",
        algorithm: .SHA1,
        digits: 6,
        secret: "sharedsecret",
        type: .totp,
        counter: 0,
        period: 30)
    
    static var testTotp15sec: OtpEntry = .init(
        issuer: "Test Issuer",
        accountName: "15sec Account",
        algorithm: .SHA1,
        digits: 6,
        secret: "sharedsecret",
        type: .totp,
        counter: 0,
        period: 15)
    
    static var testTotp60sec: OtpEntry = .init(
        issuer: "Test Issuer",
        accountName: "60sec 8digit Account",
        algorithm: .SHA1,
        digits: 8,
        secret: "sharedsecret",
        type: .totp,
        counter: 0,
        period: 60)
}
#endif
