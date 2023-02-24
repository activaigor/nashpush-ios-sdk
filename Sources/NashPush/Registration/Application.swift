import UIKit

protocol RemoteNotificationRegisterable {
    func registerForRemoteNotifications()

    var didRegisterSelector: Selector { get }
    var didFailedSelector: Selector { get }
    var didReceiveSelector: Selector { get }
}

protocol ApplicationDelegateProvider {
    var delegate: UIApplicationDelegate? { get set }
}

typealias Application = RemoteNotificationRegisterable & ApplicationDelegateProvider

extension UIApplication: Application {

    var didRegisterSelector: Selector {
        #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
    }

    var didFailedSelector: Selector {
            #selector(UIApplicationDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:))
    }

    var didReceiveSelector: Selector {
        #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:))
    }
}
