import UIKit

final class PushDialogManager {
  
  func present(dialog: PushDialog) {
    guard let visibleViewController = UIApplication.shared.visibleViewController() else { return }

    let alertController = UIAlertController(title: dialog.title, message: dialog.message, preferredStyle: .alert)
    dialog.actions
      .map { action in  UIAlertAction(title: action.title, style: .default) { _ in action.action() } }
      .forEach { alertController.addAction($0) }

    visibleViewController.present(alertController, animated: true)
  }
}
