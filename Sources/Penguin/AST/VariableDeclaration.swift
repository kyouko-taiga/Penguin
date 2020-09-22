/// A constant declaration.
public class VariableDeclaration: Declaration {

  public init(bindings: [PatternInitializer]) {
    self.bindings = bindings
  }

  public var bindings: [PatternInitializer]

}
