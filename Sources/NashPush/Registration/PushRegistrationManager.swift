import UIKit

@MainActor
final class PushRegistrationManager: NSObject {
    typealias RegistrationContinuation = CheckedContinuation<String, Error>

    static let shared = PushRegistrationManager()

    var application: Application!
    var continuation: RegistrationContinuation?
    var swizzler: SwizzleProvider!
    var notificationHandler: (([AnyHashable: Any]) -> Void)?

    func registerDevice() {
        swizzle(
            selector: application.didRegisterSelector,
            with: #selector(PushRegistrationManager.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        )

        swizzle(
            selector: application.didFailedSelector,
            with: #selector(PushRegistrationManager.application(_:didFailToRegisterForRemoteNotificationsWithError:))
        )

        swizzle(
            selector: application.didReceiveSelector,
            with: #selector(PushRegistrationManager.application(_:didReceiveRemoteNotification:fetchCompletionHandler:))
        )

        application.registerForRemoteNotifications()
    }

    private func swizzle(selector original: Selector, with selector: Selector) {
        let originalMethod = SwizzleMethod(
            selector: original,
            methodClass: application.delegate
        )

        let swizzledMethod = SwizzleMethod(
            selector: selector,
            methodClass: self
        )

        swizzler.swizzle(original: originalMethod, swizzled: swizzledMethod)
    }

    @objc
    private func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        PushRegistrationManager.shared.continuation?.resume(returning: token)
        PushRegistrationManager.shared.continuation = nil
    }

    @objc
    private func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushRegistrationManager.shared.continuation?.resume(throwing: error)
        PushRegistrationManager.shared.continuation = nil
    }

    @objc
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PushRegistrationManager.shared.notificationHandler?(userInfo)
        completionHandler(.newData)
    }
}
