import UIKit
import LKAlertController

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
    
    @IBOutlet weak var kinopubRatinView: UIStackView!
    @IBOutlet weak var kinopoiskRatingView: UIStackView!
    @IBOutlet weak var imdbRatingView: UIStackView!
    @IBOutlet weak var viewsView: UIStackView!

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
            var userinfo: [AnyHashable : Any] = ["message" : "Рейтинг КИНОПОИСК \(kinopoiskRatingLabel.text ?? "-") из 10\n Проголосовали \(item.kinopoiskVotes?.string ?? "-") человек"]
            userinfo["url"] = URL(string: "https://www.kinopoisk.ru/film/\(kinopoiskId)/")
            userinfo["buttonTitle"] = "Открыть Кинопоиск"
            tapped(view: kinopoiskRatingView, userinfo: userinfo)
        }
        
        if let imdbId = item.imdb {
            var userinfo: [AnyHashable : Any] = ["message" : "Рейтинг IMDb \(imdbRatingLabel.text ?? "-") из 10\n Проголосовали \(item.imdbVotes?.string ?? "-") человек"]
            userinfo["url"] = URL(string: "http://www.imdb.com/title/\(imdbId.fullIMDb)/")
            userinfo["buttonTitle"] = "Открыть IMDb"
            tapped(view: imdbRatingView, userinfo: userinfo)
        }
        
        if let ratingVotes = item.ratingVotes {
            let userinfo: [AnyHashable : Any] = ["message" : "Рейтинг Кинопаба \(kinopubRatingLabel.text ?? "-") (\(item.ratingPercentage ?? "-")%)\n Проголосовали \(ratingVotes.string) человек"]
            tapped(view: kinopubRatinView, userinfo: userinfo)
        }
        
        let userinfo: [AnyHashable : Any] = ["message" : "Количество просмотров данного видео в сервисе кинопаб"]
        tapped(view: viewsView, userinfo: userinfo)
    }
    
    func tapped(view: UIView, userinfo: [AnyHashable : Any]) {
        let tap = KPGestureRecognizer(target: self, action: #selector(actionOnTapView(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        tap.userView = view
        tap.userinfo = userinfo
    }
    
    @objc func actionOnTapView(_ sender: KPGestureRecognizer) {
        guard let view = sender.userView else { return }
        guard let userinfo = sender.userinfo else { return }
        guard let message = userinfo["message"] as? String else { return }
        let action = ActionSheet(message: message).tint(.kpBlack)
        if let url = userinfo["url"] as? URL, let title = userinfo["buttonTitle"] as? String {
            action.addAction(title, style: .default, handler: { (_) in
                UIApplication.shared.open(url: url)
            })
        }
        action.addAction("Отмена", style: .cancel)
        action.setPresentingSource(view)
        action.show()
    }
}
