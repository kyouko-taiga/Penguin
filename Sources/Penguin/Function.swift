public class Function: Value {

  public init(name: String) {
    self.name = name
  }

  public let name: String

  public var blocks: [InstructionBlock] = []

  public func createBlock() -> InstructionBlock {
    let block = InstructionBlock(function: self)
    blocks.append(block)
    return block
  }

  private var _nextRegister: Int = 1

  public func nextRegister() -> Int {
    let register = _nextRegister
    _nextRegister += 1
    return register
  }

  public var valueDescription: String {
    return "$\(name)"
  }

}
