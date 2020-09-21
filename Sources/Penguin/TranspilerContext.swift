public struct TranspilerContext {

  public init() {
  }

  /// The functions in the context.
  public var functions: [Function] = []

  /// The block into which new instructions are inserted.
  public var block: InstructionBlock?

  mutating func buildAlloca() -> AllocaInst {
    assert(block != nil, "Cannot create an alloca outside of an instruction block.")
    let inst = AllocaInst(id: block!.function.nextRegister())

    block!.instructions.append(inst)
    return inst
  }

  mutating func buildFunction(name: String) -> Function {
    let function = Function(name: name)

    functions.append(function)
    return function
  }

  @discardableResult
  mutating func buildStore(value: Value, destination: Value) -> StoreInst {
    assert(block != nil, "Cannot create a store outside of an instruction block.")
    let inst = StoreInst(value: value, destination: destination)

    block!.instructions.append(inst)
    return inst
  }

}
