import Foundation

enum URLParseError: Error, LocalizedError {
    case invalid(msg: String)
    case unsupported(msg: String)
    
    var errorDescription: String? {
        switch self {
        case .invalid(msg: let msg):
            "URL was invalid: \(msg)"
        case .unsupported(msg: let msg):
            "Operation not supported: \(msg)"
        }
    }

    var failureReason: String? { "Unable to parse URL" }
}

extension OtpEntry {
    static func from(url: URL) throws -> OtpEntry {
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
        
        if type == "totp" {
            let period = Int(query["period"] ?? "30") ?? 30
            return .init(issuer: issuer, accountName: accountName, algorithm: algorithm ?? .SHA1, digits: digits, secret: secret, type: .totp, counter: 0, period: period)
        } else if type == "hotp" {
            guard let counterString = query["counter"], let counter = Int64(counterString) else { throw URLParseError.invalid(msg: "HOTP codes require a initial counter value to be specified.") }
            return .init(issuer: issuer, accountName: accountName, algorithm: algorithm ?? .SHA1, digits: digits, secret: secret, type: .hotp, counter: counter, period: 0)
        }
        
        throw URLParseError.unsupported(msg: "Unknown error occured.")
    }
}

