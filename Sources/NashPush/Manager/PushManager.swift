import Foundation
import UserNotifications
import UIKit

@MainActor
final class PushManager {
    private let appKey: String
    private let settings: PushSettings
    private let authManager: PushAuthorizationManager
    private let apiManager: PushAPIManager
    private let notificationCenterDelegate: NotificationCenterDelegate
    private let storage: PushStorage
    private let logger: PushLogger
    
    init(
        appKey: String,
        settings: PushSettings = PushSettings(dialogManager: PushDialogManager()),
        authManager: PushAuthorizationManager = PushAuthorizationManager(notificationCenter: UNUserNotificationCenter.current()),
        apiManager: PushAPIManager = PushAPIManager(),
        notificationCenterDelegate: NotificationCenterDelegate = NotificationCenterDelegate(),
        storage: PushStorage = PushStorage.standard,
        logger: PushLogger = .shared
    ) {
        self.appKey = appKey
        self.settings = settings
        self.authManager = authManager
        self.apiManager = apiManager
        self.notificationCenterDelegate = notificationCenterDelegate
        self.storage = storage
        self.logger = logger

        storage.appKey = appKey
    }
    
    func register() async throws {
        notificationCenterDelegate.notificationTapped = { [weak self] response in
            self?.sendTapCallback(userInfo: response.notification.request.content.userInfo)
        }

        UNUserNotificationCenter.current().delegate = notificationCenterDelegate
        setupNotificationHandler()
        
        if let token = storage.deviceToken {
            logger.log(info: "Pending token found")
            await send(deviceToken: token)
        } else {
            await requestAuthorization()
        }
    }

    private func sendReadCallback(userInfo: [AnyHashable: Any]) {
        guard let data = notificationData(from: userInfo) else { return }

        logger.log(info: "Received remote notification: \(userInfo)")
        let message = MessageRead(messageId: data.messageId)
        let callback = Callback(token: data.subscriberToken, data: message)
        logger.log(info: "Sending callback")
        Task {
            do {
                try await apiManager.send(callback: callback, subscriberId: "\(data.subscriberId)")
                logger.log(info: "Callback sent successfully")
            } catch {
                logger.log(info: "Callback failed with: \(error.localizedDescription)")
                logger.log(error: error)
            }
        }
    }

    private func sendTapCallback(userInfo: [AnyHashable: Any]) {
        guard let data = notificationData(from: userInfo) else { return }

        logger.log(info: "Tapped on remote notification: \(userInfo)")
        let message = MessageClicked(messageId: data.messageId, actionId: data.actions.first?.action ?? "")
        let callback = Callback(token: data.subscriberToken, data: message)
        logger.log(info: "Sending callback")
        Task {
            do {
                try await apiManager.send(callback: callback, subscriberId: "\(data.subscriberId)")
                logger.log(info: "Callback sent successfully")
            } catch {
                logger.log(info: "Callback failed with: \(error.localizedDescription)")
                logger.log(error: error)
            }
        }
    }

    private func notificationData(from userInfo: [AnyHashable: Any]) -> NotificationData? {
        guard let data = userInfo["data"] as? [AnyHashable: Any] else {
            logger.log(warning: "`data` not found on notification object")
            return nil
        }

        do {
            let serializedData = try JSONSerialization.data(withJSONObject: data)

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return try decoder.decode(NotificationData.self, from: serializedData)
        } catch {
            logger.log(error: error)

            return nil
        }
    }

    private func setupNotificationHandler() {
        PushRegistrationManager.shared.notificationHandler = { [weak self] userInfo in
            self?.sendReadCallback(userInfo: userInfo)
        }
    }

    private func requestAuthorization() async {
        do {
            logger.log(info: "Requesting authorization status")
            try await authManager.requestAuthorization()
            await registerDevice()
        } catch {
            settings.settingsDialog()
        }
    }
    
    private func registerDevice() async {
        logger.log(info: "Registering device for remote notifications")
        do {
            let deviceToken: String = try await withCheckedThrowingContinuation { continuation in
                PushRegistrationManager.shared.continuation = continuation
                PushRegistrationManager.shared.swizzler = Swizzler()
                PushRegistrationManager.shared.application = UIApplication.shared
                PushRegistrationManager.shared.registerDevice()
            }
            logger.log(info: "Device registered successfully")
            
            await send(deviceToken: deviceToken)
        } catch {
            logger.log(error: error)
        }
    }
    
    private func send(deviceToken: String) async {
        logger.log(info: "Sending device token: \(deviceToken)")
        do {
            let _ = try await apiManager.send(deviceToken: deviceToken)
            logger.log(info: "Device token sent successfully")
            storage.deviceToken = nil
        } catch {
            logger.log(error: error)
            logger.log(info: "Caching device token")
            storage.deviceToken = deviceToken
        }
    }
}
