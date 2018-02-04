import UIKit

extension UIApplication {
    func open(url: URL, options: [String : Any] = [:], completionHandler: ((Bool) -> Void)? = nil) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: options, completionHandler: completionHandler)
        } else {
            let result = UIApplication.shared.openURL(url)
            completionHandler?(result)
        }
    }
}
