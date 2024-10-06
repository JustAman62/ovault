import Foundation

extension Otp {
    public static func blank() -> Otp {
        .init(id: UUID(), issuer: "", accountName: "", algorithm: .SHA1, digits: 6, secret: "", period: 30)
    }
}
