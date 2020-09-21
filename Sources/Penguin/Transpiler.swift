import Diesel

public typealias TranspilerState = (context: TranspilerContext, tokens: ArraySlice<Token>)

public enum Transpiler {

  public typealias Stream = ArraySlice<Token>

  public static func initialize() {
  }

  public static func parse(_ source: String, in context: inout TranspilerContext) {
    parse(Array(Lexer(source: source)), in: &context)
  }

  public static func parse(_ tokens: [Token], in context: inout TranspilerContext) {
    var stream = ArraySlice(tokens)

    while !stream.isEmpty && stream.first?.kind != .eof {
      // Attempt to parse a function prologue.
      if case .success(let term, let remainder) = functionPrologue.parse(stream) {
        let function = context.buildFunction(name: term.0)
        let currentBlock = context.block

        stream = remainder
        continue
      }

      // Attempt to parse a constant declaration.
      if case .success(let term, let remainder) = constantDeclaration.parse(stream) {
        for (pattern, initializer) in term {
          switch pattern {
          case .identifier:
            let alloca = context.buildAlloca()
            if let expression = initializer {
              let value = emit(expression: expression, in: &context)
              context.buildStore(value: value, destination: alloca)
            }
          }
        }

        stream = remainder
        continue
      }

      break
    }
  }

  static func emit(expression: Expression, in context: inout TranspilerContext) -> Value {
    switch expression {
    case .integer(let i):
      return ConstantInteger(value: i)
    }
  }

  // MARK: Type Signatures

  static let type = token(.identifier)
    .map({ TypeSignature.identifier(String($0.value)) })

  static let typeAnnotation = token(.colon)
    .then(newlines)
    .then(type, combine: discardLeft)

  // MARK: Expressions

  static let expression = integer

  /// integer-literal
  static let integer = token(.integer)
    .map({ (token: Token) throws -> Expression in
      guard let i = Int(token.value)
        else { throw SyntaxError(description: "Invalid integer literal '\(token.value)'.") }
      return .integer(i)
    })

  // MARK: Statements

  // MARK: Declarations

  /// constant-declaration :: `let` pattern-initializer-list
  static let constantDeclaration = token(.let_)
    .then(patternInitializerList, combine: discardLeft)

  /// variable-declaration :: `var` pattern-initializer-list
  static let variableDeclaration = token(.var_)
    .then(patternInitializerList, combine: discardLeft)

  /// pattern-initializer-list :: pattern-initializer ( `,` pattern-initializer )*
  static let patternInitializerList = patternInitializer
    .then(token(.comma)
      .surrounded(by: token(.newline))
      .then(patternInitializer, combine: discardLeft)
      .many)
    .map({ head, tail in [head] + tail })

  /// pattern-initializer :: pattern initializer?
  static let patternInitializer = pattern
    .then(initializer.optional)

  /// initializer :: `=` expression
  static let initializer = token(.assign)
    .then(expression, combine: discardLeft)

  /// function-prologue :: `func` function-name function-signature
  static let functionPrologue = token(.func_)
    .then(newlines)
    .then(functionName, combine: discardLeft)
    .then(newlines, combine: discardRight)
    .then(functionSignature)

  /// function-name :: identifier
  static let functionName = token(.identifier)
    .map({ String($0.value) })

  /// function-signature :: parameter-clause function-result?
  static let functionSignature = parameterClause
    .then(newlines.then(functionResult, combine: discardLeft).optional)

  /// parameter-clause :: `(` parameter-list? `)`
  static let parameterClause = token(.leftParen)
    .then(newlines)
    .then(parameterList.optional, combine: discardLeft)
    .then(newlines, combine: discardRight)
    .then(token(.rightParen), combine: discardRight)

  /// parameter-list :: parameter ( `,` parameter )*
  static let parameterList = parameter
    .then(token(.comma)
      .surrounded(by: token(.newline))
      .then(parameter, combine: discardLeft)
      .many)
    .map({ head, tail in [head] + tail })

  /// parameter :: parameter-name? parameter-name type-annotation?
  static let parameter = parameterName
    .then(newlines.then(parameterName, combine: discardLeft).optional)
    .then(newlines.then(typeAnnotation, combine: discardLeft).optional)

  /// parameter-name :: identifier
  static let parameterName = token(.identifier)
    .map({ String($0.value) })

  /// function-result :: `->` type
  static let functionResult = token(.arrow)
    .then(newlines)
    .then(type, combine: discardLeft)

  // MARK: Patterns

  static let pattern = identifierPattern

  /// identifier-pattern :: identifier
  static let identifierPattern = token(.identifier)
    .map({ Pattern.identifier(String($0.value)) })

  // MARK: Misc.

  /// code-block :: `{` statement-list? `}`
  static let codeBlock = token(.leftBrace)
    .then(newlines)
    .then(newlines, combine: discardRight)
    .then(token(.rightBrace), combine: discardRight)

  static let newlines = token(.newline).many

  static func token(_ kind: Token.Kind) -> TokenParser {
    return TokenParser({ $0.kind == kind })
  }

  static func discardRight<T, U>(lhs: T, rhs: U) -> T {
    return lhs
  }

  static func discardLeft<T, U>(lhs: T, rhs: U) -> U {
    return rhs
  }

}

enum TypeSignature {

  case identifier(String)

}

enum Expression {

  case integer(Int)

}

enum Pattern {

  case identifier(String)

}
