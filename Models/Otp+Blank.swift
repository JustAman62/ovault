import Foundation

extension Otp {
    public static func blank() -> Otp {
        .init(id: UUID(), issuer: "", accountName: "", domainName: "", algorithm: .SHA1, digits: 6, secret: "", period: 30)
    }
    
    public static var sample: Otp = .init(
        id: UUID(),
        issuer: "Example Corp",
        accountName: "Gold Account",
        domainName: "goldaccount.com",
        algorithm: .SHA1,
        digits: 6,
        secret: "JBSWY3DPEHPK3PXP",
        period: 30)
}
