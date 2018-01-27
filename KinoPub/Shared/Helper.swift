import UIKit

class Helper {
    /* Description: This function generate alert dialog for empty message by passing message and
     associated viewcontroller for that function
     - Parameters:
     - message: message that require for  empty alert message
     - viewController: selected viewcontroller at that time
     */
    static func EmptyMessage(message: String, viewController: UITableViewController) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height))
        messageLabel.text = message
        
        messageLabel.textColor = .kpGreyishBrown
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
//        messageLabel.font = UIFont(name: "TrebuchetMS", size: 18)
        messageLabel.sizeToFit()
        
        viewController.tableView.backgroundView = messageLabel;
        viewController.tableView.separatorStyle = .none;
    }
}
