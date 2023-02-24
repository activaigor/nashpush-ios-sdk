import XCTest

@testable import NashPush

final class PushAuthorizationManagerTests: XCTestCase {

  final class UserNotificationCenterMock: UserNotificationCenter {
    private let  mockedStatus: AuthorizationStatus
    private let shouldGrandPermissions: Bool
    init(mockedStatus: AuthorizationStatus, shouldGrandPermissions: Bool = true) {
      self.mockedStatus = mockedStatus
      self.shouldGrandPermissions = shouldGrandPermissions
    }

    func status() async throws -> AuthorizationStatus {
      return mockedStatus
    }

    var isAuthorizeCalled = false

    func authorize() async throws {
      isAuthorizeCalled = true
      if !shouldGrandPermissions {
        throw AuthorizationError.authRequestDenied
      }
    }
  }

  func testDeniedStatus() async throws {
    let notificationCenter = UserNotificationCenterMock(mockedStatus: .denied)
    let authorizationManager = PushAuthorizationManager(notificationCenter: notificationCenter)

    await XCTAssertThrowsErrorAsync(
      try await authorizationManager.requestAuthorization(),
      AuthorizationError.authRequestDenied
    )
  }

  func testNotDeterminedStatus_accessGranted() async throws {
    let notificationCenter = UserNotificationCenterMock(mockedStatus: .notDetermined)
    let authorizationManager = PushAuthorizationManager(notificationCenter: notificationCenter)

    await XCTAssertNoThrowAsync(
      try await authorizationManager.requestAuthorization()
    )
  }

  func testNotDeterminedStatus_accessDenied() async throws {
    let notificationCenter = UserNotificationCenterMock(mockedStatus: .notDetermined, shouldGrandPermissions: false)
    let authorizationManager = PushAuthorizationManager(notificationCenter: notificationCenter)

    await XCTAssertThrowsErrorAsync(
      try await authorizationManager.requestAuthorization(),
      AuthorizationError.authRequestDenied
    )
  }

  func testAuthorizedStatus() async throws {
    let notificationCenter = UserNotificationCenterMock(mockedStatus: .authorized)
    let authorizationManager = PushAuthorizationManager(notificationCenter: notificationCenter)

    await XCTAssertNoThrowAsync(
      try await authorizationManager.requestAuthorization()
    )
  }
}
