import Foundation

extension OtpMetadata {
    public static func blank() -> OtpMetadata {
        .init(id: UUID(), issuer: "", accountName: "", algorithm: .SHA1, digits: 6, secret: "", type: .totp, counter: 0, period: 30)
    }
}
