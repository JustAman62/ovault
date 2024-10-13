import Foundation

#if DEBUG
public extension Otp {
    static var testTotp30sec: Otp = .init(
        id: UUID(),
        issuer: "Example Issuer",
        accountName: "Account Name",
        domainName: "example.com",
        algorithm: .SHA1,
        digits: 6,
        secret: "JBSWY3DPEHPK3PXP",
        period: 30)
    
    static var testTotp15sec: Otp = .init(
        id: UUID(),
        issuer: "Google",
        accountName: "My Email",
        domainName: "google.com",
        algorithm: .SHA1,
        digits: 6,
        secret: "JBSWY3DPEHPK3PXP",
        period: 15)
    
    static var testTotp60sec: Otp = .init(
        id: UUID(), 
        issuer: "GitHub",
        accountName: "GitHub Account",
        domainName: "github.com",
        algorithm: .SHA1,
        digits: 8,
        secret: "JBSWY3DPEHPK3PXP",
        period: 60)
}
#endif
