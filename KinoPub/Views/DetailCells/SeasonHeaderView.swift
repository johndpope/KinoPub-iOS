import UIKit

class SeasonHeaderView: UICollectionReusableView {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .kpBlackTwo
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.roundCorners([.topLeft, .bottomLeft], radius: 6)
    }
    
}
