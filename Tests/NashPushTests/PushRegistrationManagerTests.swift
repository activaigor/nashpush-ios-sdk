import XCTest
@testable import NashPush

final class MockedApp: Application {
    var deviceToken: String?
    var error: Error?
    var info: [AnyHashable: Any]?

    var delegate: UIApplicationDelegate? = MockedAppDelegate()

    var didRegisterSelector: Selector {
        #selector(MockedAppDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
    }

    var didFailedSelector: Selector {
        #selector(MockedAppDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:))
    }

    var didReceiveSelector: Selector {
        #selector(MockedAppDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:))
    }

    func registerForRemoteNotifications() {
        if let deviceToken {
            delegate?.perform(didRegisterSelector, with: deviceToken.data(using: .utf8))
        } else if let error {
            delegate?.perform(didFailedSelector, with: error)
        } else if let info {
            let fetchCompletionHandler: (UIBackgroundFetchResult) -> Void = { _ in }
            delegate?.perform(didReceiveSelector, with: info, with: fetchCompletionHandler)
        }
    }
}

final class MockedAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        XCTFail()
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        XCTFail()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        XCTFail()
    }
}

@MainActor
final class PushRegistrationManagerTests: XCTestCase {

    func testReceivingApplicationToken() async throws {
        let token = UUID().uuidString
        let expected = Data(token.utf8).map { String(format: "%02x", $0)}.joined()

        let app = MockedApp()
        app.deviceToken = token
        PushRegistrationManager.shared.application = app
        PushRegistrationManager.shared.swizzler = Swizzler()
        let deviceToken: String = try await withCheckedThrowingContinuation { continuation in
            PushRegistrationManager.shared.continuation = continuation
            PushRegistrationManager.shared.registerDevice()
        }

        XCTAssertEqual(expected, deviceToken)
    }

    func testReceiveError() async {
        enum RegistrationError: Error {
            case kernel
        }

        let app = MockedApp()
        app.error = RegistrationError.kernel
        PushRegistrationManager.shared.application = app
        PushRegistrationManager.shared.swizzler = Swizzler()
        do {
            _ = try await withCheckedThrowingContinuation { continuation in
                PushRegistrationManager.shared.continuation = continuation
                PushRegistrationManager.shared.registerDevice()
            }

            XCTFail()
        } catch {
            XCTAssertTrue(error is RegistrationError)
        }
    }
}
