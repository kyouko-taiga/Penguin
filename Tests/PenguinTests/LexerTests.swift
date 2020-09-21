import Penguin
import XCTest

final class LexerTests: XCTestCase {

  func testPunctuation() {
    let input = ",()"
    var lexer = Lexer(source: input)

    XCTAssertEqual(lexer.next()?.kind, .comma)
    XCTAssertEqual(lexer.next()?.kind, .leftParen)
    XCTAssertEqual(lexer.next()?.kind, .rightParen)
  }

  func testKeywords() {
    var lexer: Lexer

    lexer = Lexer(source: "func")
    XCTAssertEqual(lexer.next()?.kind, .func_)

    lexer = Lexer(source: "let")
    XCTAssertEqual(lexer.next()?.kind, .let_)
  }

}
