public protocol Instruction {

  var instructionDescription: String { get }

}

public struct AllocaInst: Instruction, Value {

  public let id: Int

  public var valueDescription: String {
    return String(describing: id)
  }

  public var instructionDescription: String {
    return "%\(id) = alloca"
  }

}

public struct CallInst: Instruction, Value {

  public let id: Int

  public let function: Value

  public let arguments: [Value]

  public var valueDescription: String {
    return String(describing: id)
  }

  public var instructionDescription: String {
    let args = arguments.map({ $0.valueDescription }).joined(separator: ", ")
    return "%\(id) = call \(function.valueDescription)(\(args))"
  }

}

public struct StoreInst: Instruction {

  public let value: Value

  public let destination: Value

  public var instructionDescription: String {
    return "store \(value.valueDescription), \(destination.valueDescription)"
  }

}
