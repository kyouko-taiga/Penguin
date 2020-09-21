import Diesel

struct EmitParser<Base, Element>: Diesel.Parser
  where Base: Diesel.Parser, Base.Stream == TranspilerState
{

  init(_ base: Base, emit: @escaping (Base.Element, inout TranspilerContext) -> (Element)) {
    self.base = base
    self.emit = emit
  }

  let base: Base

  let emit: (Base.Element, inout TranspilerContext) -> (Element)

  func parse(_ state: TranspilerState) -> ParseResult<Element, TranspilerState> {
    switch base.parse(state) {
    case .success(let output, var state):
      let newOutput = emit(output, &state.context)
      return .success(newOutput, state)

    case .failure(let error):
      return .failure(error)
    }
  }

}

extension Diesel.Parser {

  func emit<R>(
    _ fn: @escaping (Element, inout TranspilerContext) -> R
  ) -> EmitParser<Self, R> {
    return EmitParser(self, emit: fn)
  }

}
