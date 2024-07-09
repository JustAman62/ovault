import Foundation

#if DEBUG
public extension OtpMetadata {
    static var testTotp30sec: OtpMetadata = .init(
        id: UUID(),
        issuer: "Test Issuer",
        accountName: "30sec Account",
        algorithm: .SHA1,
        digits: 6,
        secret: "sharedsecret",
        type: .totp,
        counter: 0,
        period: 30)
    
    static var testTotp15sec: OtpMetadata = .init(
        id: UUID(),
        issuer: "Test Issuer",
        accountName: "15sec Account",
        algorithm: .SHA1,
        digits: 6,
        secret: "sharedsecret",
        type: .totp,
        counter: 0,
        period: 15)
    
    static var testTotp60sec: OtpMetadata = .init(
        id: UUID(), 
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
