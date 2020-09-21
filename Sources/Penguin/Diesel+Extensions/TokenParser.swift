import Diesel

struct TokenParser: Diesel.Parser {

  init(_ predicate: @escaping (Token) -> Bool, onFailure: ((Transpiler.Stream) -> Any)? = nil) {
    self.predicate = predicate
    self.onFailure = onFailure
  }

  let predicate: (Token) -> Bool

  let onFailure: ((Transpiler.Stream) -> Any)?

  func parse(_ stream: Transpiler.Stream) -> ParseResult<Token, Transpiler.Stream> {
    guard let first = stream.first, predicate(first)
      else { return .error(diagnostic: onFailure?(stream)) }
    return .success(first, stream.dropFirst())
  }

}
