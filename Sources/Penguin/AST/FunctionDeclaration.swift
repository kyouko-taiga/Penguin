public class FunctionDeclaration: Declaration {

  public init(
    name: String,
    parameters: [ParameterDeclaration],
    result: TypeSignature?,
    body: [Statement]?
  ) {
    self.name = name
    self.parameters = parameters
    self.result = result
    self.body = body
  }

  public var name: String

  public var parameters: [ParameterDeclaration]

  public var result: TypeSignature?

  public var body: [Statement]?

}
