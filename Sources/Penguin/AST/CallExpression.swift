public struct CallExpression: Expression {

  public init(callee: Expression, arguments: [Argument]) {
    self.callee = callee
    self.arguments = arguments
  }

  public var callee: Expression

  public var arguments: [Argument]

}
