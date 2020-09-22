import Diesel

public enum Parser {

  public typealias Stream = ArraySlice<Token>

  public static func initialize() {
    defineExpression()
    defineStatement()
  }

  public static func parse(_ source: String) {
    parse(Array(Lexer(source: source)))
  }

  public static func parse(_ tokens: [Token]) {
    switch statementList.parse(ArraySlice(tokens)) {
    case .success(let ast, let remainder):
      print(ast)
      print(remainder)

    case .failure(let error):
      print(error)
    }
  }

  static let statementList = statement
    .surrounded(by: newlines)
    .many

  // MARK: Type Signatures

  static let type = token(.identifier)
    .map({ TypeSignature.identifier(String($0.value)) })

  static let typeAnnotation = token(.colon)
    .then(newlines)
    .then(type, combine: discardLeft)

  // MARK: Expressions

  static let expression = ForwardParser<Expression, Stream>()

  static func defineExpression() {
    let value = primaryExpression
      .then(trailer.optional)
      .map({ (head, tail) -> Expression in
        switch tail {
        case .argumentClause(let arguments):
          return CallExpression(callee: head, arguments: arguments ?? [])
        case nil:
          return head
        }
      })

    expression.define(value)
  }

  static let primaryExpression = identifier.map({ $0 as Expression })
    .else(integer.map({ $0 as Expression }))

  enum Trailer {

    case argumentClause([Argument]?)

  }

  static let trailer = argumentClause

  static let argumentClause = token(.leftParen)
    .then(newlines)
    .then(argumentList.optional, combine: discardLeft)
    .then(newlines, combine: discardRight)
    .then(token(.rightParen), combine: discardRight)
    .map({ Trailer.argumentClause($0) })

  static let argumentList = argument
    .then(token(.comma)
      .surrounded(by: token(.newline))
      .then(argument, combine: discardLeft)
      .many)
    .map({ head, tail in [head] + tail })

  static let argument = labeledArgument
    .else(expression.map({ Argument(label: nil, value: $0) }))

  static let labeledArgument = token(.identifier)
    .then(token(.colon).surrounded(by: token(.newline)), combine: discardRight)
    .then(expression)
    .map({ Argument(label: String($0.0.value), value: $0.1) })

  static let identifier = token(.identifier)
    .map({ Identifier(name: String($0.value)) })

  /// integer-literal
  static let integer = token(.integer)
    .map({ (token: Token) throws -> IntegerLiteral in
      guard let i = Int(token.value)
        else { throw SyntaxError(description: "Invalid integer literal '\(token.value)'.") }
      return IntegerLiteral(value: i)
    })

  // MARK: Statements

  static let statement = ForwardParser<Statement, Stream>()

  static func defineStatement() {
    let value = expression.map({ $0 as Statement })
      .else(declaration.map({ $0 as Statement }))
      .else(returnStatement.map({ $0 as Statement }))
      .then(statementEnd, combine: discardRight)

    statement.define(value)
  }

  static let statementEnd = token(.newline)
    .else(token(.semicolon))
    .else(token(.eof))

  /// return-statement :: `return` expression?
  static let returnStatement = token(.return_)
    .then(newlines)
    .then(expression.optional, combine: discardLeft)
    .map({ ReturnStatement(value: $0) })

  // MARK: Declarations

  static let declaration =
    constantDeclaration.map({ $0 as Declaration })
      .else(variableDeclaration.map({ $0 as Declaration }))
      .else(functionDeclaration.map({ $0 as Declaration }))

  /// constant-declaration :: `let` pattern-initializer-list
  static let constantDeclaration = token(.let_)
    .then(patternInitializerList, combine: discardLeft)
    .map({ ConstantDeclaration(bindings: $0) })

  /// variable-declaration :: `var` pattern-initializer-list
  static let variableDeclaration = token(.var_)
    .then(patternInitializerList, combine: discardLeft)
    .map({ VariableDeclaration(bindings: $0) })

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
    .then(newlines)
    .then(expression, combine: discardLeft)

  /// function-declaration :: function-prologue code-block
  static let functionDeclaration = functionPrologue
    .then(newlines, combine: discardRight)
    .then(codeBlock)
    .map({ (decl, body) -> FunctionDeclaration in
      decl.body = body
      return decl
    })

  /// function-prologue :: `func` function-name function-signature
  static let functionPrologue = token(.func_)
    .then(newlines)
    .then(functionName, combine: discardLeft)
    .then(newlines, combine: discardRight)
    .then(functionSignature)
    .map({ (term) -> FunctionDeclaration in
      FunctionDeclaration(
        name: term.0,
        parameters: term.1.0 ?? [],
        result: term.1.1,
        body: nil)
    })

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
    .map({ (term) -> ParameterDeclaration in
      ParameterDeclaration(
        externalName  : term.0.0,
        localName     : term.0.1 ?? term.0.0,
        typeAnnotation: term.1)
    })

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
    .then(statementList, combine: discardLeft)
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
