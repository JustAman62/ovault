import Foundation

#if DEBUG
public extension Otp {
    static var testTotp30sec: Otp = .init(
        id: UUID(),
        issuer: "Test Issuer",
        accountName: "30sec Account",
        algorithm: .SHA1,
        digits: 6,
        secret: "JBSWY3DPEHPK3PXP",
        period: 30)
    
    static var testTotp15sec: Otp = .init(
        id: UUID(),
        issuer: "Test Issuer",
        accountName: "15sec Account",
        algorithm: .SHA1,
        digits: 6,
        secret: "JBSWY3DPEHPK3PXP",
        period: 15)
    
    static var testTotp60sec: Otp = .init(
        id: UUID(), 
        issuer: "Test Issuer",
        accountName: "60sec 8digit Account",
        algorithm: .SHA1,
        digits: 8,
        secret: "JBSWY3DPEHPK3PXP",
        period: 60)
}
#endif
