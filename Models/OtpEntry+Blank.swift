import Foundation

extension OtpEntry {
    public static func blank() -> OtpEntry {
        .init(issuer: "", accountName: "", algorithm: .SHA1, digits: 6, secret: "", type: .totp, counter: 0, period: 30)
    }
}
