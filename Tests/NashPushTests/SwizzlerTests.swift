import XCTest
@testable import NashPush

final class SwizzlerTests: XCTestCase {

    final class OriginalMethodClass: NSObject {
        @objc
        func originalMethod() {
            XCTFail()
        }
    }

    final class SwizzledMethodsClass: NSObject {
        static var shared = SwizzledMethodsClass()
        var expectation: XCTestExpectation!

        @objc
        func swizzledMethod() {
            SwizzledMethodsClass.shared.expectation.fulfill()
        }
    }

    func testSwizzleMethod() {
        let originalInstance = OriginalMethodClass()
        let originalSelector = #selector(OriginalMethodClass.originalMethod)
        let originalMethod = SwizzleMethod(selector: originalSelector, methodClass: originalInstance)

        let swizzledSelector = #selector(SwizzledMethodsClass.swizzledMethod)
        let swizzledMethod = SwizzleMethod(selector: swizzledSelector, methodClass: SwizzledMethodsClass.shared)

        let expectation = expectation(description: "Swizzled method call expectation")
        SwizzledMethodsClass.shared.expectation = expectation

        let swizzler = Swizzler()
        swizzler.swizzle(original: originalMethod, swizzled: swizzledMethod)

        originalInstance.perform(originalSelector)
        waitForExpectations(timeout: 0.01)
    }
}
