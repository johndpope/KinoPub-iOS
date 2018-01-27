import UIKit

class HintsView: UIView {
    
    @IBOutlet weak var hintLabel: UILabel!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
    }
    
    func configView() {
        backgroundColor = .clear
        hintLabel.textColor = .kpGreyishBrown
    }
    
    func setHint(text: String) {
        hintLabel.text = text
    }

}
