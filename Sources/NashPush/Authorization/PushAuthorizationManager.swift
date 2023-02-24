import Foundation

final class PushAuthorizationManager {
  private let notificationCenter: UserNotificationCenter

  init(notificationCenter: UserNotificationCenter) {
    self.notificationCenter = notificationCenter
  }

  @MainActor
  func requestAuthorization() async throws {
    let authorizationStatus = try await notificationCenter.status()
    switch authorizationStatus {
    case .authorized:
      break
    case .notDetermined:
      try await notificationCenter.authorize()
    case .denied:
      throw AuthorizationError.authRequestDenied
    }
  }
}
