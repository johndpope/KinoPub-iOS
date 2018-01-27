import UIKit
import AlamofireImage
import SwiftyUserDefaults

protocol ItemCollectionViewCellDelegate {
    func didPressDeleteButton(_ item: Item)
    func didPressMoveButton(_ item: Item)
}

class ItemCollectionViewCell: UICollectionViewCell {

    var item: Item!
    var delegate: ItemCollectionViewCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var posterView: UIView!
//    @IBOutlet weak var enTitleLabel: UILabel!
    @IBOutlet weak var newEpisodeView: UIView!
    @IBOutlet weak var newEpisodeLabel: UILabel!
    @IBOutlet weak var kinopoiskRatingLabel: UILabel!
    @IBOutlet weak var imdbRatingLabel: UILabel!
    @IBOutlet weak var kinopubRatingLabel: UILabel!
    @IBOutlet weak var ratingView: UIView!
    
    @IBOutlet weak var kinopoiskImageView: UIImageView!
    @IBOutlet weak var imdbImageView: UIImageView!
    @IBOutlet weak var kinopubImageView: UIImageView!
    
    @IBOutlet weak var editBookmarkView: UIView!
    @IBOutlet weak var deleteFromBookmarkButton: UIButton!
    @IBOutlet weak var moveFromBookmarkButton: UIButton!
    
    @IBAction func deleteFromBookmarkButtonPressed(_ sender: UIButton) {
        delegate?.didPressDeleteButton(self.item)
    }
    @IBAction func moveFromBookmarkButtonPressed(_ sender: UIButton) {
        delegate?.didPressMoveButton(self.item)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        editBookmarkView.isHidden = true
        newEpisodeView.isHidden = true
        newEpisodeLabel.isHidden = true
        ratingView.isHidden = true
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale

        configViews()
        configBlur()
    }
    
    func configViews() {
        titleLabel.textColor = .kpOffWhite
        
        kinopoiskRatingLabel.textColor = .kpOffWhite
        imdbRatingLabel.textColor = .kpOffWhite
        kinopubRatingLabel.textColor = .kpOffWhite
        
        kinopoiskImageView.image = kinopoiskImageView.image?.withRenderingMode(.alwaysTemplate)
        kinopoiskImageView.tintColor = .kpOffWhite
        imdbImageView.image = imdbImageView.image?.withRenderingMode(.alwaysTemplate)
        imdbImageView.tintColor = .kpOffWhite
        kinopubImageView.image = kinopubImageView.image?.withRenderingMode(.alwaysTemplate)
        kinopubImageView.tintColor = .kpOffWhite
        
        posterView.dropShadow(color: UIColor.black, opacity: 0.3, offSet: CGSize(width: 0, height: 2), radius: 6, scale: true)
        posterView.addObserver(self, forKeyPath: #keyPath(UIView.bounds), options: .new, context: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        posterView.layer.shadowPath = UIBezierPath(rect: posterView.bounds).cgPath
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
    }
    
    
    func configBlur() {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            ratingView.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.ratingView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            ratingView.insertSubview(blurEffectView, at: 0)
        } else {
            ratingView.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.80)
        }
    }

    func set(item: Item) {
        self.item = item
        editBookmarkView.isHidden = true
        newEpisodeView.isHidden = true
        newEpisodeLabel.isHidden = true
        ratingView.isHidden = true
        if let title = item.title?.components(separatedBy: " / ") {
            titleLabel.text = title[0]
//            enTitleLabel.text = title.count > 1 ? title[1] : ""
        }

        if let poster = item.posters?.medium {
            posterImageView.af_setImage(withURL: URL(string: poster)!,
                                             placeholderImage: UIImage(named: "poster-placeholder.png"),
                                             imageTransition: .crossDissolve(0.2),
                                             runImageTransitionIfCached: false)
        }
        

        if let newEpisode = item.new {
            newEpisodeView.isHidden = false
            newEpisodeLabel.isHidden = false
            newEpisodeLabel.text = String(newEpisode)
        }
        
        if Defaults[.showRatringInPoster] {
            if let kinopoiskRating = item.kinopoiskRating {
                kinopoiskRatingLabel.text = String(format: "%.1f", kinopoiskRating)
                ratingView.isHidden = false
            } else {
                
            }
            
            if let imdbRating = item.imdbRating {
                imdbRatingLabel.text = imdbRating.string
                ratingView.isHidden = false
                
            }
            
            if let kinopubRating = item.rating {
                kinopubRatingLabel.text = kinopubRating.string
                ratingView.isHidden = false
            }
        }
        

    }
    
    func configure(with collection: Collections) {
        if let title = collection.title {
            titleLabel.text = title
        }
        
        if let poster = collection.posters?.medium {
            posterImageView.af_setImage(withURL: URL(string: poster)!,
                                        placeholderImage: UIImage(named: "poster-placeholder.png"),
                                        imageTransition: .crossDissolve(0.2),
                                        runImageTransitionIfCached: false)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let objectView = object as? UIView,
            objectView === posterView,
            keyPath == #keyPath(UIView.bounds) {
            posterView.layer.shadowPath = UIBezierPath(rect: objectView.bounds).cgPath
        }
    }
    
    deinit {
        posterView.removeObserver(self, forKeyPath: #keyPath(UIView.bounds))
    }

}
