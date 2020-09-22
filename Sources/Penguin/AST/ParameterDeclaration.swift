public class ParameterDeclaration: Declaration {

  public init(externalName: String, localName: String, typeAnnotation: TypeSignature?) {
    self.externalName = externalName
    self.localName = localName
    self.typeAnnotation = typeAnnotation
  }

  public var externalName: String

  public var localName: String

  public var typeAnnotation: TypeSignature?

}
