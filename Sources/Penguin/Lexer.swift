public struct Lexer: IteratorProtocol, Sequence {

  public init(source: String) {
    self.source = source
    self.index = source.startIndex
  }

  private var source: String

  private var index: String.Index

  // private var location = SourceLocation(line: 1, column: 1, offset: 0)

  private var depleted = false

  public mutating func next() -> Token? {
    guard !depleted
      else { return nil }

    // Ignore whitespaces, except newlines.
    take(while: { $0.isWhitespace && !$0.isNewline })

    // Lex the end of file.
    guard let ch = peek() else {
      depleted = true
      return Token(kind: .eof, value: source[index ..< index])
    }

    let start = index

    // Lex statement delimiters.
    if ch.isNewline {
      take(while: { $0.isWhitespace || $0 == ";" })
      return Token(
        kind: (ch == ";") ? .semicolon : .newline,
        value: source[start ..< source.index(after: start)])
    }

    // Lex identifiers and keywords.
    if ch.isLetter || ch == "_" {
      let identifier = take(while: { $0.isLetter || $0.isNumber || $0 == "_" })

      switch identifier {
      case "return" : return Token(kind: .return_, value: source[start ..< index])
      case "func"   : return Token(kind: .func_, value: source[start ..< index])
      case "let"    : return Token(kind: .let_, value: source[start ..< index])
      case "var"    : return Token(kind: .var_, value: source[start ..< index])
      default       : return Token(kind: .identifier, value: source[start ..< index])
      }
    }

    // Lex number literals.
    if ch.isDigit {
      take(while: { $0.isDigit })
      return Token(kind: .integer, value: source[start ..< index])
    }

    // Lex operators and punctuation.
    let operator_ = peek(while: { $0.isOperatorOrPunctuation })
    var kind: Token.Kind?

    switch operator_.prefix(2) {
    case "->" : kind = .arrow
    default   : break
    }

    if let k = kind {
      take(n: 2)
      return Token(kind: k, value: source[start ..< index])
    }

    switch operator_.first {
    case "="  : kind = .assign
    case ","  : kind = .comma
    case ":"  : kind = .colon
    case "("  : kind = .leftParen
    case ")"  : kind = .rightParen
    case "{"  : kind = .leftBrace
    case "}"  : kind = .rightBrace
    default   : break
    }

    if let k = kind {
      take()
      return Token(kind: k, value: source[start ..< index])
    }

    take()
    return Token(kind: .unknown, value: source[start ..< index])
  }

  private func peek() -> Character? {
    guard index < source.endIndex
      else { return nil }
    return source[index]
  }

  private func peek(at offset: Int) -> Character? {
    let position = source.index(index, offsetBy: offset)
    guard position < source.endIndex
      else { return nil }
    return source[position]
  }

  private func peek(n: Int) -> Substring {
    return source.suffix(from: index).prefix(n)
  }

  private func peek(while predicate: (Character) -> Bool) -> Substring {
    return source.suffix(from: index).prefix(while: predicate)
  }

  @discardableResult
  private mutating func take() -> Character {
    let character = source[index]
    index = source.index(after: index)
    return character
  }

  @discardableResult
  private mutating func take(n: Int) -> Substring {
    let characters = source.suffix(from: index).prefix(n)
    index = source.index(index, offsetBy: characters.count)
    return characters
  }

  @discardableResult
  private mutating func take(while predicate: (Character) -> Bool) -> Substring {
    var end = index
    while end < source.endIndex && predicate(source[end]) {
      end = source.index(after: end)
    }

    let characters = source[index ..< end]
    index = end
    return characters
  }

}
