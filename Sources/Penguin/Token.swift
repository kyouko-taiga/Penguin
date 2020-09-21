public struct Token {

  public init(kind: Kind, value: Substring) {
    self.kind = kind
    self.value = value
  }

  public let kind: Kind

  public let value: Substring

  public enum Kind {

    // MARK: Identifiers & Keywords

    case identifier

    case func_
    case let_
    case return_
    case var_

    // MARK: Literals

    case integer

    // MARK: Operators

    case assign

    // MARK: Punctuation

    case eof
    case newline

    case comma
    case semicolon
    case colon
    case arrow

    case leftParen
    case rightParen
    case leftBrace
    case rightBrace

    case unknown

  }

}
