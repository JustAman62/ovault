import Foundation
import CryptoKit
internal import Base32

public enum OtpError: Error, LocalizedError {
    case unexpectedSecretFormat
    
    public var errorDescription: String? {
        switch self {
        case .unexpectedSecretFormat:
            "Secret was in an unexpected format, unable to decode"
        }
    }
}

extension OtpMetadata {  
    internal func getOtp(secret: String) throws -> String {
        return switch self.type {
        case .totp: try calculateOtp(alg: self.algorithm, key: secret, counter: self.timeStep, digits: self.digits)
        case .hotp: try calculateOtp(alg: self.algorithm, key: secret, counter: self.counter, digits: self.digits)
        }
    }
    
    /// - Parameters:
    ///     - `alg`: The algorhitm to use for hashing as part of the OTP generation
    ///     - `key`: The Base32 encoded secret key
    ///     - `counter`: The data to hash with the key
    ///     - `digits`: The number of digits to be extracted
    ///
    private func calculateOtp(alg: HashAlgorithm, key: String, counter: Int64, digits: Int) throws -> String {
        guard let decodedKey = Base32.base32DecodeToData(key) else { throw OtpError.unexpectedSecretFormat }
        let counterBytes = withUnsafeBytes(of: counter.bigEndian, { Data($0) })
        
        let hmac: Data = switch alg {
        case .SHA1: Data(HMAC<Insecure.SHA1>.authenticationCode(for: counterBytes, using: .init(data: decodedKey)))
        case .SHA256: Data(HMAC<SHA256>.authenticationCode(for: counterBytes, using: .init(data: decodedKey)))
        case .SHA512: Data(HMAC<SHA512>.authenticationCode(for: counterBytes, using: .init(data: decodedKey)))
        }
        
        // Get the last byte of data, and extract the last 4 bits of that byte
        let offset = hmac[hmac.endIndex - 1] & 0x0F
        
        // This offset becomes the start point of the 4 bytes we want from the hash
        let truncatedHash = hmac[offset...offset + 3]

        // Ignore the first bit of the data
        let number = UInt64(truncatedHash.base16EncodedString, radix: 16)! & 0x7FFFFFFF
        
        // Calculate the remainder of modulo as the OTP
        let otpDigits = Int(number % UInt64(pow(10, Double(digits))))
        
        let otpString = otpDigits.description
        
        let paddingDigits = digits - otpString.count
        let padding = String(repeating: "0", count: paddingDigits)
        
        return padding + otpString
    }
}
