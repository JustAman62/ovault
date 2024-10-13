import Foundation

public enum URLParseError: Error, LocalizedError {
    case invalid(msg: String)
    case unsupported(msg: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalid(msg: let msg):
            "URL was invalid: \(msg)"
        case .unsupported(msg: let msg):
            "Operation not supported: \(msg)"
        }
    }

    public var failureReason: String? { "Unable to parse URL" }
}

extension Otp {
    public static func from(url: URL) throws -> Otp {
        guard url.scheme == "otpauth" || url.scheme == "ovault-otpauth" else { throw URLParseError.unsupported(msg: "Only otpauth URLs are supported.") }
        let components = url.pathComponents

        guard components.count == 2 else { throw URLParseError.invalid(msg: "Expected 2 path components (including /).") }
        guard let type = url.host(), type == "totp" else { throw URLParseError.unsupported(msg: "Currently only TOTPs are supported.") }
        
        guard let label = components[1].removingPercentEncoding else { throw URLParseError.invalid(msg: "Unable to parse first part of the URL.") }
        
        let labelParts = label.split(separator: ":")
        var issuer: String? = if labelParts.count == 2 { String(labelParts[0]) } else { nil }
        
        let accountName = if labelParts.count == 2 { String(labelParts[1]) } else { String(labelParts[0]) }
        
        guard let query = url.queryParameters else { throw URLParseError.invalid(msg: "Expected query parameters.") }
        guard let secret = query["secret"] else { throw URLParseError.invalid(msg: "A shared secret is expected.") }
        if let queryIssuer = query["issuer"] {
            issuer = queryIssuer
        }
        
        guard let issuer else { throw URLParseError.invalid(msg: "Expected an Issuer to be specified in the URL.") }
        
        let algorithm = if let queryAlgorithm = query["algorithm"] { HashAlgorithm(rawValue: queryAlgorithm) } else { HashAlgorithm.SHA1 }
        let digits = Int(query["digits"] ?? "6") ?? 6
        
        let period = Int(query["period"] ?? "30") ?? 30
        let domainName = issuer.contains(".") ? issuer : "\(issuer).com"
        return .init(id: UUID(), issuer: issuer, accountName: accountName, domainName: domainName, algorithm: algorithm ?? .SHA1, digits: digits, secret: secret, period: period)
    }
}

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
