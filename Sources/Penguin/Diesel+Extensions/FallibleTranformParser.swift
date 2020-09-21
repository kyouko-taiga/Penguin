import Diesel

/// A parser that transforms the result of another parser, if the latter is successful.
struct FallibleTransformParser<Base, Element>: Diesel.Parser where Base: Diesel.Parser {

  init(_ base: Base, transform: @escaping (Base.Element) throws -> Element) {
    self.base = base
    self.transform = transform
  }

  private let base: Base

  private let transform: (Base.Element) throws -> Element

  func parse(_ stream: Base.Stream) -> ParseResult<Element, Base.Stream> {
    switch base.parse(stream) {
    case .success(let output, let remainder):
      do {
        return .success(try transform(output), remainder)
      } catch {
        return .error(diagnostic: error)
      }

    case .failure(let error):
      return .failure(error)
    }
  }

}

extension Diesel.Parser {

  func map<R>(_ transform: @escaping (Element) throws -> R) -> FallibleTransformParser<Self, R> {
    return FallibleTransformParser(self, transform: transform)
  }

}
