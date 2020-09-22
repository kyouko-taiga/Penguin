public protocol Expression: Statement {
}

public struct Identifier: Expression {

  public init(name: String) {
    self.name = name
  }

  public var name: String

}

public struct IntegerLiteral: Expression {

  public init(value: Int) {
    self.value = value
  }

  public var value: Int

}
