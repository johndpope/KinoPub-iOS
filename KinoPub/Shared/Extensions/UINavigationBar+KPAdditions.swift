import UIKit

extension UINavigationBar {
    func clean(_ clean: Bool) {
        if clean {
            self.isTranslucent = true
            self.setBackgroundImage(UIImage(), for: .default)
            self.shadowImage = UIImage()
        } else {
            self.setBackgroundImage(nil, for: UIBarMetrics.default)
            self.shadowImage = nil
            self.isTranslucent = true
        }
    }
}
