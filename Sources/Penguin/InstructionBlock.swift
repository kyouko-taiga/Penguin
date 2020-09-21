public class InstructionBlock {

  public init(function: Function) {
    self.function = function
  }

  public unowned let function: Function

  public var instructions: [Instruction] = []

}
