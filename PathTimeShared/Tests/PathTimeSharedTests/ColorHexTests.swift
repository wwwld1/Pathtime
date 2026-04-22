import XCTest
import SwiftUI
@testable import PathTimeShared

final class ColorHexTests: XCTestCase {

    func test_validHex_withoutHash() {
        XCTAssertNotNil(Color(hex: "FF0000"))
    }

    func test_validHex_withHash() {
        XCTAssertNotNil(Color(hex: "#FF0000"))
    }

    func test_validHex_lowercase() {
        XCTAssertNotNil(Color(hex: "ff0000"))
    }

    func test_validHex_black() {
        XCTAssertNotNil(Color(hex: "000000"))
    }

    func test_validHex_white() {
        XCTAssertNotNil(Color(hex: "FFFFFF"))
    }

    func test_validHex_knownLineColor_D93B26() {
        XCTAssertNotNil(Color(hex: "D93B26"))
    }

    func test_validHex_leadingTrailingWhitespace() {
        XCTAssertNotNil(Color(hex: "  FF0000  "))
    }

    func test_returns_nil_forEmptyString() {
        XCTAssertNil(Color(hex: ""))
    }

    func test_returns_nil_for3DigitHex() {
        XCTAssertNil(Color(hex: "FFF"))
    }

    func test_returns_nil_for5DigitHex() {
        XCTAssertNil(Color(hex: "FF573"))
    }

    func test_returns_nil_for7DigitHex() {
        XCTAssertNil(Color(hex: "FF5733A"))
    }

    func test_returns_nil_for8DigitHex() {
        XCTAssertNil(Color(hex: "FF5733AA"))
    }

    // 已知问题：无效十六进制字符（如"GG5733"）通过长度检查（6位），
    // Scanner 解析失败时 rgb=0，导致返回黑色而不是 nil。
    func test_invalidHexChars_KNOWN_ISSUE_returnsBlackInsteadOfNil() {
        XCTExpectFailure("Known bug: invalid hex chars pass length check and Scanner returns 0 (black) instead of nil")
        XCTAssertNil(Color(hex: "GG5733"))
    }
}
