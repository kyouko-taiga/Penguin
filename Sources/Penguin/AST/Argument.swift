public struct Argument {

  public init(label: String?, value: Expression) {
    self.label = label
    self.value = value
  }

  public var label: String?

  public var value: Expression

}
