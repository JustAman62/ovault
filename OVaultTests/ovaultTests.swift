import XCTest
@testable import OVault
@testable import Models

final class ovauliTests: XCTestCase {
    func testParseStandard() throws {
        // Arrange
        let input = URL(string: "otpauth://totp/Example:alice@google.com?secret=JBSWY3DPEHPK3PXP&issuer=Example")!
        
        // Act
        let (entry, secret) = try OtpMetadata.from(url: input)
        
        // Assert
        XCTAssertNotNil(entry)
        XCTAssertEqual(.totp, entry.type)
        XCTAssertEqual("Example", entry.issuer)
        XCTAssertEqual("alice@google.com", entry.accountName)
        XCTAssertEqual("JBSWY3DPEHPK3PXP", secret)
    }
    
    func testGenerator6DigitHexSHA1() {
        hotpTest(counter: 0, digits: 6, expected: "755224")
        hotpTest(counter: 1, digits: 6, expected: "287082")
        hotpTest(counter: 0, digits: 7, expected: "4755224")
        hotpTest(counter: 1, digits: 7, expected: "4287082")
    }
    
    private func hotpTest(counter: Int64, digits: Int, expected: String) {
        let secret = "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ"
        let entry = OtpMetadata(
            id: UUID(),
            issuer: "Issuer",
            accountName: "Account Name",
            algorithm: .SHA1,
            digits: digits,
            period: 0)
        XCTAssertEqual(try entry.getOtp(secret: secret), expected)
    }
}
