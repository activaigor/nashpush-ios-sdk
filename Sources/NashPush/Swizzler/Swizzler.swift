import Foundation

struct SwizzleMethod {
  let selector: Selector
  let methodClass: Any?
}

protocol SwizzleProvider {
    func swizzle(original: SwizzleMethod, swizzled: SwizzleMethod)
}

final class Swizzler: SwizzleProvider {

  public func swizzle(original: SwizzleMethod, swizzled: SwizzleMethod) {
    let swizzledClass: AnyClass? = object_getClass(swizzled.methodClass)
    let originalClass: AnyClass? = object_getClass(original.methodClass)

    guard let swizzledMethod = class_getInstanceMethod(swizzledClass, swizzled.selector) else { return }

    if let originalMethod = class_getInstanceMethod(originalClass, original.selector) {
      method_exchangeImplementations(originalMethod, swizzledMethod)
    } else {
      let implementation = method_getImplementation(swizzledMethod)
      let encoding = method_getTypeEncoding(swizzledMethod)
      class_addMethod(originalClass, swizzled.selector, implementation, encoding)
    }
  }
}
