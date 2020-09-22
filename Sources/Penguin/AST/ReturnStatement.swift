public class ReturnStatement: Statement {

  public init(value: Expression?) {
    self.value = value
  }

  public var value: Expression?

}
