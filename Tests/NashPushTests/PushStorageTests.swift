import XCTest

@testable import NashPush

final class PushStorageTests: XCTestCase {

  override func tearDown() {
    PushStorage().deviceToken = nil
  }

  func testSaveDeviceToken() {
    let storage = PushStorage()
    let expectedToken = UUID().uuidString

    XCTAssertNil(storage.deviceToken)
    storage.deviceToken = expectedToken
    XCTAssertNotNil(storage.deviceToken)
  }

  func testRemoveDeviceToken() {
    let storage = PushStorage()
    storage.deviceToken = UUID().uuidString

    XCTAssertNotNil(storage.deviceToken)
    storage.deviceToken = nil
    XCTAssertNil(storage.deviceToken)
  }
}
