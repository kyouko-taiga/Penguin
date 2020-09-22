/// A constant declaration.
public class ConstantDeclaration: Declaration {

  public init(bindings: [PatternInitializer]) {
    self.bindings = bindings
  }

  public var bindings: [PatternInitializer]

}
