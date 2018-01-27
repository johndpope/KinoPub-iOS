import UIKit

class DetailTableView: UITableView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
            
//            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
//                return true
//            }
            
//            if subview is UIButton {
//                let foundButton = subview as! UIButton
//                if foundButton.isEnabled, !foundButton.isHidden, foundButton.point(inside: convert(point, to: foundButton), with: event) {
//                    return true
//                }
//            }
        }
        return false
    }

}
