import UIKit

class RatingTableViewCell: UITableViewCell {

    @IBOutlet weak var kinopoiskRatingLabel: UILabel!
    @IBOutlet weak var imdbRatingLabel: UILabel!
    @IBOutlet weak var kinopubRatingLabel: UILabel!
    @IBOutlet weak var kinopubViewsLabel: UILabel!

    @IBOutlet weak var kinopoiskLabel: UILabel!
    @IBOutlet weak var imdbLabel: UILabel!
    @IBOutlet weak var kinopubLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    
    @IBOutlet weak var kinopoiskImageView: UIImageView!
    @IBOutlet weak var imdbImageView: UIImageView!
    @IBOutlet weak var kinopubImageView: UIImageView!
    @IBOutlet weak var viewsImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureLabels()
    }

    func configureLabels() {
        backgroundColor = .clear
        kinopoiskRatingLabel.textColor = .kpOffWhite
        imdbRatingLabel.textColor = .kpOffWhite
        kinopubRatingLabel.textColor = .kpOffWhite
        kinopubViewsLabel.textColor = .kpOffWhite

        kinopoiskLabel.textColor = .kpGreyishBrown
        imdbLabel.textColor = .kpGreyishBrown
        kinopubLabel.textColor = .kpGreyishBrown
        viewsLabel.textColor = .kpGreyishBrown
        
        kinopoiskImageView.image = kinopoiskImageView.image?.withRenderingMode(.alwaysTemplate)
        kinopoiskImageView.tintColor = .kpOffWhite
        imdbImageView.image = imdbImageView.image?.withRenderingMode(.alwaysTemplate)
        imdbImageView.tintColor = .kpOffWhite
        kinopubImageView.image = kinopubImageView.image?.withRenderingMode(.alwaysTemplate)
        kinopubImageView.tintColor = .kpOffWhite
        viewsImageView.image = viewsImageView.image?.withRenderingMode(.alwaysTemplate)
        viewsImageView.tintColor = .kpOffWhite
    }

    func configure(withItem item: Item) {
        kinopoiskRatingLabel.text = String(format: "%.1f", item.kinopoiskRating ?? 0)
        kinopoiskRatingLabel.addCharactersSpacing(-0.4)
        
        imdbRatingLabel.text = item.imdbRating?.string ?? "0.0"
        imdbRatingLabel.addCharactersSpacing(-0.4)
        
        kinopubRatingLabel.text = item.rating?.double.kmFormatted ?? "0"
        kinopubRatingLabel.addCharactersSpacing(-0.4)
        
        kinopubViewsLabel.text = item.views?.double.kmFormatted ?? "0"
        kinopubViewsLabel.addCharactersSpacing(-0.4)
        
        if let kinopoiskId = item.kinopoisk {
            tappedLabel(label: kinopoiskRatingLabel, urlStr: "https://www.kinopoisk.ru/film/\(kinopoiskId)/")
        }
        
        if let imdbId = item.imdb {
            tappedLabel(label: imdbRatingLabel, urlStr: "http://www.imdb.com/title/\(imdbId.fullIMDb)/")
        }
    }
    
    func tappedLabel(label: UILabel, urlStr: String) {
        let url = URL(string: urlStr)
        let tap = KPGestureRecognizer(target: self, action: #selector(openURL(_:)))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        tap.url = url
    }
    
    @objc func openURL(_ sender: KPGestureRecognizer) {
        if let url = sender.url {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
