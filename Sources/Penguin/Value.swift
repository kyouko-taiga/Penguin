public protocol Value {

  var valueDescription: String { get }

}

public struct ConstantInteger: Value {

  public let value: Int

  public var valueDescription: String {
    return String(describing: value)
  }

}
