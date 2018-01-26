//
//  RatingTableViewCell.swift
//  KinoPub
//
//  Created by hintoz on 29.05.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

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
        backgroundColor = .clear
        configureLabels()
    }

    func configureLabels() {
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
        if let kinopoiskRating = item.kinopoiskRating {
            kinopoiskRatingLabel.text = String(format: "%.1f", kinopoiskRating)
            kinopoiskRatingLabel.addCharactersSpacing(-0.4)
        }
        
        if let kinopoiskId = item.kinopoisk {
            tappedLabel(label: kinopoiskRatingLabel, urlStr: "https://www.kinopoisk.ru/film/\(kinopoiskId)/")
        }
        
        if let imdbId = item.imdb {
            tappedLabel(label: imdbRatingLabel, urlStr: "http://www.imdb.com/title/\(imdbId.fullIMDb)/")
        }
        
        if let imdbRating = item.imdbRating {
            imdbRatingLabel.text = String(imdbRating)
            imdbRatingLabel.addCharactersSpacing(-0.4)
        }
        if let kinopubRating = item.rating {
            kinopubRatingLabel.text = kinopubRating.double.kmFormatted
            kinopubRatingLabel.addCharactersSpacing(-0.4)
        }
        if let kinopubViews = item.views {
            kinopubViewsLabel.text = kinopubViews.double.kmFormatted
            kinopubViewsLabel.addCharactersSpacing(-0.4)
        }
    }
    
    func tappedLabel(label: UILabel, urlStr: String) {
        let url = URL(string: urlStr)
        let tap = KPGestureRecognizer(target: self, action: #selector(openURL(_:)))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
//        label.underlineTextStyle()
//        label.textColor = UIColor.kpLightGreen
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
