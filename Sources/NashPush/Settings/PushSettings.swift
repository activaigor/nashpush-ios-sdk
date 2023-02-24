import UIKit

final class PushSettings {
  private let dialogManager: PushDialogManager

  init(dialogManager: PushDialogManager) {
    self.dialogManager = dialogManager
  }

  @MainActor
  func settingsDialog() {
    let title = "Open Settings"
    let message = "Push notifications turned off. Open settings to re-enable them"
    let openAction = PushDialogAction(title: "Open") { [weak self] in
      self?.openSettings()
    }
    let cancelAction = "Cancel"

    let dialog = PushDialog(title: title, message: message, actions: [openAction], cancel: cancelAction)
    dialogManager.present(dialog: dialog)
  }

  private func openSettings() {
    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
      fatalError("Unable to produce URL for Settings")
    }

    guard UIApplication.shared.canOpenURL(settingsURL) else {
      fatalError("Unable to open Settings URL")
    }

    UIApplication.shared.open(settingsURL)
  }
}
