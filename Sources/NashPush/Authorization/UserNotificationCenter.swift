import Foundation
import UserNotifications

protocol UserNotificationCenter {
  func status() async throws -> AuthorizationStatus
  func authorize() async throws
}

extension UNUserNotificationCenter: UserNotificationCenter {
  func status() async throws -> AuthorizationStatus {
    try await withCheckedThrowingContinuation { continuation in
      getNotificationSettings { settings in
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
          continuation.resume(returning: .authorized)
        case .denied:
          continuation.resume(returning: .denied)
        case .notDetermined:
          continuation.resume(returning: .notDetermined)
        @unknown default:
          continuation.resume(throwing: AuthorizationError.unknownStatus)
        }
      }
    }
  }

  func authorize() async throws {
    let isGranted = try await requestAuthorization(options: [.alert, .badge, .sound])
    if !isGranted { throw AuthorizationError.authRequestDenied }
  }
}
