import UIKit

extension UIApplication {
    
    var keyWindow: UIWindow? {
        UIApplication
            .shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
    }
    
    func visibleViewController(_ root: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = root as? UINavigationController {
            return visibleViewController(navigationController)
        }
        
        if
            let tabBarController = root as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController
        {
            return visibleViewController(selectedViewController)
        }
        
        if let presentedViewController = root?.presentedViewController {
            return visibleViewController(presentedViewController)
        }
        
        return root
    }
}
