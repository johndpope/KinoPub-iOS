import UIKit

extension UINavigationController {
    open override func childViewControllerForHomeIndicatorAutoHidden() -> UIViewController? {
        return topViewController
    }
}
