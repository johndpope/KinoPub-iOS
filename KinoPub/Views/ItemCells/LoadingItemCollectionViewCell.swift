import UIKit

class LoadingItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    static let reuseIdentifier = "LoadingItemCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        loadingIndicator.color = .kpOffWhite
    }

    func set(moreToLoad: Bool) {
        if moreToLoad {
            loadingIndicator.startAnimating()
            loadingIndicator.isHidden = false
        } else {
            loadingIndicator.stopAnimating()
        }
    }

}
