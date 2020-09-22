import Diesel

struct TokenParser: Diesel.Parser {

  init(_ predicate: @escaping (Token) -> Bool, onFailure: ((Parser.Stream) -> Any)? = nil) {
    self.predicate = predicate
    self.onFailure = onFailure
  }

  let predicate: (Token) -> Bool

  let onFailure: ((Parser.Stream) -> Any)?

  func parse(_ stream: Parser.Stream) -> ParseResult<Token, Parser.Stream> {
    guard let first = stream.first, predicate(first)
      else { return .error(diagnostic: onFailure?(stream)) }
    return .success(first, stream.dropFirst())
  }

}
