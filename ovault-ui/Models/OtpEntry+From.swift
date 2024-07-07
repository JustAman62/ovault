import Foundation

extension OtpEntry {
    static func from(url: URL) -> OtpEntry? {
        guard url.scheme == "otpauth" else { return nil }
        let components = url.pathComponents

        guard components.count == 2 else { return nil }
        guard let type = url.host(), type == "totp" || type == "hotp" else { return nil }
        
        guard let label = components[1].removingPercentEncoding else { return nil }
        
        let labelParts = label.split(separator: ":")
        var issuer: String? = if labelParts.count == 2 { String(labelParts[0]) } else { nil }
        
        let accountName = if labelParts.count == 2 { String(labelParts[1]) } else { String(labelParts[0]) }
        
        guard let query = url.queryParameters else { return nil }
        guard let secret = query["secret"] else { return nil }
        if let queryIssuer = query["issuer"] {
            issuer = queryIssuer
        }
        
        guard let issuer else { return nil }
        
        let algorithm = if let queryAlgorithm = query["algorithm"] { HashAlgorithm(rawValue: queryAlgorithm) } else { HashAlgorithm.SHA1 }
        let digits = Int(query["digits"] ?? "6") ?? 6
        
        if type == "totp" {
            let period = Int(query["period"] ?? "30") ?? 30
            return .init(issuer: issuer, accountName: accountName, algorithm: algorithm ?? .SHA1, digits: digits, secret: secret, type: .totp, counter: 0, period: period)
        } else if url.host() == "hotp" {
            guard let counterString = query["counter"], let counter = Int64(counterString) else { return nil }
            return .init(issuer: issuer, accountName: accountName, algorithm: algorithm ?? .SHA1, digits: digits, secret: secret, type: .hotp, counter: counter, period: 0)
        }
        
        return nil
    }
}

