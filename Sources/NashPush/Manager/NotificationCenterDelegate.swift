import UserNotifications

final class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {

    var notificationTapped: ((UNNotificationResponse) -> Void)?
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.sound, .badge, .banner]
    }

    @MainActor
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        notificationTapped?(response)
    }
}
